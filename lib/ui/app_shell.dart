import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/library_controller.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'widgets/mini_player.dart';

enum AppDest { home, search, library }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppDest _dest = AppDest.home;
  bool _didScan = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didScan || !mounted) return;
      _didScan = true;
      context.read<LibraryController>().scanDeviceLibrary(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      (AppDest.home, l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      (AppDest.search, l10n.navSearch, Icons.search_rounded, Icons.search_rounded),
      (AppDest.library, l10n.navLibrary, Icons.library_music_outlined, Icons.library_music_rounded),
    ];

    final body = IndexedStack(
      index: _dest.index,
      children: const [
        HomeScreen(),
        SearchScreen(),
        LibraryScreen(),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.black,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          if (wide) {
            return Scaffold(
              backgroundColor: SwColors.background,
              body: Row(
                children: [
                  NavigationRail(
                    backgroundColor: Colors.black,
                    selectedIndex: _dest.index,
                    onDestinationSelected: (index) {
                      setState(() => _dest = AppDest.values[index]);
                    },
                    labelType: NavigationRailLabelType.all,
                    leading: const SizedBox(height: SwSpacing.sm),
                    destinations: [
                      for (final dest in destinations)
                        NavigationRailDestination(
                          icon: Icon(dest.$3),
                          selectedIcon: Icon(dest.$4),
                          label: Text(dest.$2),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1, color: Color(0x14FFFFFF)),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: body),
                        const MiniPlayer(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            backgroundColor: SwColors.background,
            body: Column(
              children: [
                Expanded(child: body),
                const MiniPlayer(),
              ],
            ),
            bottomNavigationBar: ColoredBox(
              color: Colors.black,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      for (final dest in destinations)
                        Expanded(
                          child: _NavItem(
                            label: dest.$2,
                            icon: dest.$3,
                            selectedIcon: dest.$4,
                            selected: _dest == dest.$1,
                            onTap: () => setState(() => _dest = dest.$1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SwColors.secondary : const Color(0xFF8E8E8E);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class AdaptivePage extends StatelessWidget {
  const AdaptivePage({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final margin = width >= 840 ? SwSpacing.screenMarginMedium : SwSpacing.screenMarginCompact;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: SwSpacing.maxContentWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: margin),
          child: child,
        ),
      ),
    );
  }
}
