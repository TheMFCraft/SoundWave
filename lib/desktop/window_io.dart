import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initDesktopWindow() async {
  if (!(Platform.isLinux || Platform.isWindows || Platform.isMacOS)) return;
  try {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(840, 560),
      title: 'SoundWave',
      backgroundColor: Color(0xFF121212),
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setTitle('SoundWave');
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (_) {}
}
