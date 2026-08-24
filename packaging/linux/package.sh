#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  VERSION="$(awk -F'[:+]' '/^version:/{print $2; exit}' "$ROOT/pubspec.yaml" | tr -d ' ')"
fi

BUNDLE="$ROOT/build/linux/x64/release/bundle"
if [ ! -x "$BUNDLE/soundwave" ]; then
  echo "Linux bundle missing. Run: flutter build linux --release" >&2
  exit 1
fi

DIST="$ROOT/dist"
APPDIR="$DIST/AppDir"
rm -rf "$APPDIR"
mkdir -p "$DIST" "$APPDIR/usr/bin" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -a "$BUNDLE/." "$APPDIR/usr/bin/"
cp "$ROOT/packaging/linux/soundwave.desktop" "$APPDIR/usr/share/applications/soundwave.desktop"
cp "$ROOT/packaging/linux/soundwave.desktop" "$APPDIR/soundwave.desktop"
cp "$ROOT/assets/brand/app_icon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/soundwave.png"
cp "$ROOT/assets/brand/app_icon.png" "$APPDIR/soundwave.png"

cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
cd "$HERE/usr/bin" || exit 1
exec ./soundwave "$@"
EOF
chmod +x "$APPDIR/AppRun" "$APPDIR/usr/bin/soundwave"

TAR="$DIST/soundwave-${VERSION}-linux-x64.tar.gz"
tar -C "$BUNDLE" -czf "$TAR" .

DEB_ROOT="$DIST/deb"
rm -rf "$DEB_ROOT"
mkdir -p "$DEB_ROOT/DEBIAN" "$DEB_ROOT/opt/soundwave" "$DEB_ROOT/usr/bin" \
  "$DEB_ROOT/usr/share/applications" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps"
cp -a "$BUNDLE/." "$DEB_ROOT/opt/soundwave/"
cat > "$DEB_ROOT/usr/bin/soundwave" << 'EOF'
#!/bin/sh
cd /opt/soundwave || exit 1
exec ./soundwave "$@"
EOF
chmod +x "$DEB_ROOT/usr/bin/soundwave" "$DEB_ROOT/opt/soundwave/soundwave"
cp "$ROOT/packaging/linux/soundwave.desktop" "$DEB_ROOT/usr/share/applications/soundwave.desktop"
sed -i 's|^Exec=soundwave|Exec=/usr/bin/soundwave|' "$DEB_ROOT/usr/share/applications/soundwave.desktop"
cp "$ROOT/assets/brand/app_icon.png" "$DEB_ROOT/usr/share/icons/hicolor/256x256/apps/soundwave.png"
SIZE="$(du -sk "$DEB_ROOT" | awk '{print $1}')"
cat > "$DEB_ROOT/DEBIAN/control" << EOF
Package: soundwave
Version: ${VERSION}
Section: sound
Priority: optional
Architecture: amd64
Installed-Size: ${SIZE}
Maintainer: Cylone <hello@cylone.de>
Description: Local music player by Cylone
 SoundWave plays audio that already lives on the device.
EOF
dpkg-deb --build "$DEB_ROOT" "$DIST/soundwave-${VERSION}-linux-amd64.deb"

if command -v appimagetool >/dev/null 2>&1 || [ -x "$DIST/appimagetool" ]; then
  TOOL="$(command -v appimagetool || true)"
  [ -z "$TOOL" ] && TOOL="$DIST/appimagetool"
  ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$TOOL" "$APPDIR" "$DIST/soundwave-${VERSION}-linux-x64.AppImage"
else
  echo "appimagetool not found; skipped AppImage" >&2
fi

echo "Linux packages in $DIST"
