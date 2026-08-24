#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  VERSION="$(awk -F'[:+]' '/^version:/{print $2; exit}' "$ROOT/pubspec.yaml" | tr -d ' ')"
fi

APP="$ROOT/build/macos/Build/Products/Release/SoundWave.app"
if [ ! -d "$APP" ]; then
  APP="$ROOT/build/macos/Build/Products/Release/soundwave.app"
fi
if [ ! -d "$APP" ]; then
  echo "macOS app missing. Run: flutter build macos --release" >&2
  exit 1
fi

DIST="$ROOT/dist"
mkdir -p "$DIST"
STAGE="$DIST/dmg-stage"
rm -rf "$STAGE"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/SoundWave.app"
hdiutil create -volname "SoundWave" -srcfolder "$STAGE" -ov -format UDZO \
  "$DIST/soundwave-${VERSION}-macos.dmg"
rm -rf "$STAGE"
echo "macOS disk image in $DIST"
