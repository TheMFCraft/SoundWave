# SoundWave

Local music player by **Cylone**. SoundWave plays audio that already lives on the device. There is no streaming, no account and no ads.

**Package:** `de.cylone.soundwave`  
**Play Store:** [play.google.com/store/apps/details?id=de.cylone.soundwave](https://play.google.com/store/apps/details?id=de.cylone.soundwave)  
**Closed testing:** [play.google.com/apps/testing/de.cylone.soundwave](https://play.google.com/apps/testing/de.cylone.soundwave)  
**Releases:** [github.com/TheMFCraft/SoundWave/releases](https://github.com/TheMFCraft/SoundWave/releases)  
**Repository:** [github.com/TheMFCraft/SoundWave](https://github.com/TheMFCraft/SoundWave)

## Features

- Scan device music (MediaStore and folders) or import files
- Home, search, library, albums, artists and playlists
- Mini player and full-screen now playing
- Queue, shuffle, repeat, playback speed and sleep timer
- Likes, playlists and long-press context menus
- Optional lyrics lookup via [LRCLIB](https://lrclib.net)
- Background playback, media notification and Android home-screen widget
- Local Jam: one device plays, others control the queue and send missing files for the session
- Desktop apps for Windows, Linux and macOS
- German and English
- Everything stays on the device except optional lyrics requests (title, artist, album, duration)

## Requirements

- Flutter SDK (see `pubspec.yaml` for the Dart SDK constraint)
- Android Studio / Xcode command-line tools for platform builds
- Android: audio permission (`READ_MEDIA_AUDIO` / storage on older versions)
- Linux desktop: GTK 3, and GStreamer for playback
- Windows may prompt for a firewall exception when a Jam is hosted

## Getting started

```bash
flutter pub get
flutter run
```

Desktop:

```bash
flutter run -d linux
flutter run -d windows
flutter run -d macos
```

Release APK:

```bash
flutter build apk --release
```

Play Store bundle (needs `android/key.properties` and your keystore, both gitignored):

```bash
flutter build appbundle --release
```

Desktop installers (also built by GitHub Actions on `v*` tags):

```bash
flutter build linux --release && ./packaging/linux/package.sh
flutter build windows --release   # then Inno Setup: packaging/windows/soundwave.iss
flutter build macos --release && ./packaging/macos/package.sh
```

## Project layout

| Path | Purpose |
| --- | --- |
| `lib/` | Flutter app |
| `android/` | Android host, widget, MediaStore, Jam hotspot |
| `linux/` `windows/` `macos/` | Desktop runners |
| `packaging/` | AppImage, deb, Inno Setup, DMG |
| `website/` | Static site (privacy policy + landing) |
| `assets/brand/` | App icon and logo |

## Closed testing

1. Join the tester group: [soundwave-testing](https://groups.google.com/g/soundwave-testing)
2. Open the opt-in page: [play.google.com/apps/testing/de.cylone.soundwave](https://play.google.com/apps/testing/de.cylone.soundwave)
3. Install from the Play listing: [de.cylone.soundwave](https://play.google.com/store/apps/details?id=de.cylone.soundwave)

## Privacy

SoundWave does not use advertising IDs, analytics or accounts.  
Jam traffic stays on the local network.  
Privacy policy page: [`website/datenschutz.html`](website/datenschutz.html)

## Website

The `website/` folder is a static site. Deploy the folder contents to [Netlify](https://www.netlify.com/) (or set the publish directory to `website`). A move to `cylone.de` is planned for a later version.

## Play protection

The Android app requests a Play Integrity token on startup (license, app and device signals). Playback is never blocked if Play services are missing.

Enable extra verdicts in Play Console → **App-Integrität** / **Play Integrity API**:

- Recent device activity
- Play Protect status
- App access risk

Console-only (not in app code):

- **Installationen auf riskanten Geräten verhindern** under Store protection
- Play Billing protection — skip, SoundWave has no in-app purchases

After this change, upload a new AAB so Play can detect the Integrity API.

## License

All rights reserved unless a license file is added.
