import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'state/library_controller.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';
import 'data/models.dart';

class SoundWaveApp extends StatelessWidget {
  const SoundWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryController>(
      builder: (context, library, _) {
        return MaterialApp(
          title: 'SoundWave',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          locale: switch (library.settings.language) {
            AppLanguage.system => null,
            AppLanguage.en => const Locale('en'),
            AppLanguage.de => const Locale('de'),
          },
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: library.ready ? const AppShell() : const _LaunchScreen(),
        );
      },
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, size: 72, color: Color(0xFFDAB9FF)),
            SizedBox(height: 16),
            Text(
              'SoundWave',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFFDAB9FF),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(width: 36, height: 36, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
