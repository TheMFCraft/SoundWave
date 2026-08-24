import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../jam/jam_screen.dart';
import '../settings/settings_screen.dart';

class SoundWaveHeader extends StatelessWidget {
  const SoundWaveHeader({super.key, this.leading});

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: SwColors.background.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      titleSpacing: 0,
      leadingWidth: 64,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: leading ??
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/brand/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, _, _) => const Icon(Icons.graphic_eq_rounded, color: SwColors.primary),
                ),
              ),
        ),
      ),
      title: Text(
        l10n.appName,
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontSize: 26,
              height: 1,
              color: SwColors.primary,
            ),
      ),
      actions: [
        IconButton(
          tooltip: l10n.jamTitle,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const JamScreen()));
          },
          icon: const Icon(Icons.graphic_eq_rounded, color: SwColors.secondary),
        ),
        IconButton(
          tooltip: l10n.settings,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
          },
          icon: const Icon(Icons.settings_outlined, color: SwColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
