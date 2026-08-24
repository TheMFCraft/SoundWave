# SoundWave

Local music player by **Cylone**. SoundWave plays audio that already lives on the device. There is no streaming, no account and no ads.

**Package:** `de.cylone.soundwave`  
**Play Store:** [play.google.com/store/apps/details?id=de.cylone.soundwave](https://play.google.com/store/apps/details?id=de.cylone.soundwave)  
**Closed testing:** [play.google.com/apps/testing/de.cylone.soundwave](https://play.google.com/apps/testing/de.cylone.soundwave)  
**Repository:** [github.com/TheMFCraft/SoundWave](https://github.com/TheMFCraft/SoundWave)

## Features

- Scan device music (MediaStore and folders) or import files
- Home, search, library, albums, artists and playlists
- Mini player and full-screen now playing
- Queue, shuffle, repeat, playback speed and sleep timer
- Likes, playlists and long-press context menus
- Optional lyrics lookup via [LRCLIB](https://lrclib.net)
- Background playback, media notification and Android home-screen widget
- German and English
- Everything stays on the device except optional lyrics requests (title, artist, album, duration)

## Requirements

- Flutter SDK (see `pubspec.yaml` for the Dart SDK constraint)
- Android Studio / Xcode command-line tools for platform builds
- Android: audio permission (`READ_MEDIA_AUDIO` / storage on older versions)

## Getting started

```bash
flutter pub get
flutter run
```

Release APK:

```bash
flutter build apk --release
```

Play Store bundle (needs `android/key.properties` and your keystore, both gitignored):

```bash
flutter build appbundle --release
```

## Project layout

| Path | Purpose |
| --- | --- |
| `lib/` | Flutter app |
| `android/` | Android host, widget, MediaStore channel |
| `website/` | Static site for Netlify (privacy policy + landing) |
| `assets/brand/` | App icon and logo |

## Closed testing

1. Join the tester group: [soundwave-testing](https://groups.google.com/g/soundwave-testing)
2. Open the opt-in page: [play.google.com/apps/testing/de.cylone.soundwave](https://play.google.com/apps/testing/de.cylone.soundwave)
3. Install from the Play listing: [de.cylone.soundwave](https://play.google.com/store/apps/details?id=de.cylone.soundwave)

## Privacy

SoundWave does not use advertising IDs, analytics or accounts.  
Privacy policy page: [`website/datenschutz.html`](website/datenschutz.html)

## Website

The `website/` folder is a static site. Deploy the folder contents to [Netlify](https://www.netlify.com/) (or set the publish directory to `website`).

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
