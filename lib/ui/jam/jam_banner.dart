import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../jam/jam.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../jam/jam_screen.dart';

class JamBanner extends StatelessWidget {
  const JamBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final jam = context.watch<JamController>();
    if (!jam.isActive) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final player = jam.members.where((member) => member.isPlayer).firstOrNull;
    final label = jam.isPlayer
        ? l10n.jamHosting(jam.members.length)
        : l10n.jamListening(player?.name ?? jam.deviceName);
    return Material(
      color: const Color(0xFF1A1224),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const JamScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, color: SwColors.secondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SwColors.secondary,
                      ),
                ),
              ),
              TextButton(
                onPressed: jam.stop,
                child: Text(l10n.jamLeave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
