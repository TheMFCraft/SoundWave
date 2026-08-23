import 'package:flutter/material.dart';

/// Nocturne palette from the SoundWave design system.
abstract final class SwColors {
  static const background = Color(0xFF121212);
  static const surface = Color(0xFF131313);
  static const surfaceContainer = Color(0xFF1E1E1E);
  static const surfaceContainerLow = Color(0xFF1C1B1B);
  static const surfaceContainerHigh = Color(0xFF2A2A2A);
  static const surfaceContainerHighest = Color(0xFF353534);
  static const surfaceContainerLowest = Color(0xFF0E0E0E);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFCDC3D4);
  static const outline = Color(0xFF978D9D);
  static const outlineVariant = Color(0xFF4B4452);
  static const primary = Color(0xFFDAB9FF);
  static const onPrimary = Color(0xFF460283);
  static const primaryContainer = Color(0xFFBB86FC);
  static const onPrimaryContainer = Color(0xFF4C0F89);
  static const secondary = Color(0xFF46F5E0);
  static const onSecondary = Color(0xFF003731);
  static const secondaryContainer = Color(0xFF00D8C4);
  static const onSecondaryContainer = Color(0xFF005950);
  static const tertiary = Color(0xFFFFB2BC);
  static const onTertiary = Color(0xFF600F26);
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const inversePrimary = Color(0xFF7743B5);

  static const neon = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static ColorScheme get scheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        error: error,
        onError: onError,
        surface: background,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        inverseSurface: onSurface,
        onInverseSurface: Color(0xFF313030),
        inversePrimary: inversePrimary,
        surfaceTint: primary,
      );
}
