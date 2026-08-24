import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/play_integrity.dart';
import 'desktop/window.dart';
import 'jam/jam.dart';
import 'state/library_controller.dart';
import 'state/player_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDesktopWindow();
  final mobile = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (mobile) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'de.cylone.soundwave.audio',
        androidNotificationChannelName: 'SoundWave',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
    } catch (_) {}
  }

  final library = LibraryController();
  await library.load();
  final player = PlayerController(library);
  await player.init();
  final jam = JamController(player: player, library: library);
  unawaited(warmUpPlayIntegrity());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: player),
        ChangeNotifierProvider.value(value: jam),
      ],
      child: const SoundWaveApp(),
    ),
  );
}
