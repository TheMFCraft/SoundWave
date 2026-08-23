import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = SwColors.scheme;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
    );
    final text = _nocturneText(GoogleFonts.interTextTheme(base.textTheme));

    return base.copyWith(
      scaffoldBackgroundColor: SwColors.background,
      canvasColor: SwColors.background,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: text.headlineMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
        elevation: 0,
        height: 72,
        indicatorColor: scheme.secondary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.secondary : scheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: selected ? scheme.secondary : scheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: SwColors.background,
        indicatorColor: scheme.secondary.withValues(alpha: 0.14),
        selectedIconTheme: IconThemeData(color: scheme.secondary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.secondary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: scheme.primary,
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
        selectedColor: scheme.primary,
        labelStyle: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w700),
        backgroundColor: const Color(0xFF2A2A2A),
        checkmarkColor: scheme.onPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x991E1E1E),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        activeTrackColor: scheme.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        thumbColor: scheme.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        elevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.1), space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static TextTheme _nocturneText(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 48,
        fontSize: 48,
        height: 56 / 48,
        color: SwColors.primary,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 32,
        fontSize: 32,
        height: 40 / 32,
        color: SwColors.primary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 24,
        fontSize: 24,
        height: 32 / 24,
        color: SwColors.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 24 / 18,
        color: SwColors.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 24 / 16),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 20 / 14),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.6,
      ),
    );
  }
}
