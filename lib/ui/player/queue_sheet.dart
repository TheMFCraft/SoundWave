import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../jam/jam.dart';
import '../../l10n/app_localizations.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../widgets/track_tile.dart';

Future<void> showQueueSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const QueueSheet(),
  );
}

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = context.watch<PlayerController>();
    final jam = context.watch<JamController>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) {
        if (player.queue.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text(l10n.queueEmpty)),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.queue, style: Theme.of(context).textTheme.headlineMedium)),
                  TextButton(onPressed: player.clearQueue, child: Text(l10n.clearQueue)),
                ],
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                scrollController: controller,
                itemCount: player.queue.length,
                onReorderItem: player.moveQueueItem,
                itemBuilder: (context, index) {
                  final track = player.queue[index];
                  final jamItem = jam.isActive && index < jam.items.length ? jam.items[index] : null;
                  return Material(
                    key: ValueKey(track.id + index.toString()),
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TrackTile(
                          track: track,
                          playing: index == player.index,
                          contextQueue: player.queue,
                          contextIndex: index,
                          playContext: player.context,
                          onRemoveFromQueue: () => player.removeFromQueue(index),
                          onTap: () => player.skipTo(index),
                          trailing: IconButton(
                            onPressed: () => player.removeFromQueue(index),
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                          ),
                        ),
                        if (jamItem != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
                            child: Text(
                              _jamMeta(l10n, jamItem),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: SwColors.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _jamMeta(AppLocalizations l10n, JamQueueItem item) {
    final who = l10n.jamAddedBy(item.addedByName);
    final status = switch (item.transfer) {
      JamTransferStatus.pending => l10n.jamTransferPending,
      JamTransferStatus.transferring => l10n.jamTransferProgress((item.progress * 100).round()),
      JamTransferStatus.failed => l10n.jamTransferFailed,
      JamTransferStatus.ready => l10n.jamTransferReady,
      JamTransferStatus.local => l10n.jamTransferLocal,
    };
    return '$who · $status';
  }
}
