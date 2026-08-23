import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/player_controller.dart';
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
                  return Material(
                    key: ValueKey(track.id + index.toString()),
                    color: Colors.transparent,
                    child: TrackTile(
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
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
