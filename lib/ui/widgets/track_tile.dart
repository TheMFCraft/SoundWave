import 'package:flutter/material.dart';

import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../theme/colors.dart';
import 'artwork.dart';
import 'context_sheet.dart';
import 'playing_bars.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.playing = false,
    this.dense = false,
    this.trailing,
    this.leading,
    this.onLongPress,
    this.contextQueue,
    this.contextIndex = 0,
    this.playContext,
    this.onRemoveFromPlaylist,
    this.onRemoveFromQueue,
    this.enableContextMenu = true,
  });

  final Track track;
  final VoidCallback onTap;
  final bool playing;
  final bool dense;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onLongPress;
  final List<Track>? contextQueue;
  final int contextIndex;
  final QueueContext? playContext;
  final VoidCallback? onRemoveFromPlaylist;
  final VoidCallback? onRemoveFromQueue;
  final bool enableContextMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      onLongPress:
          onLongPress ??
          (!enableContextMenu
              ? null
              : () => showTrackContext(
                  context,
                  track: track,
                  queue: contextQueue,
                  index: contextIndex,
                  playContext: playContext,
                  onRemoveFromPlaylist: onRemoveFromPlaylist,
                  onRemoveFromQueue: onRemoveFromQueue,
                )),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: dense ? 56 : 64,
        child: Row(
          children: [
            leading ??
                Artwork(track: track, size: dense ? 40 : 48, borderRadius: 8),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: playing ? scheme.secondary : scheme.onSurface,
                    ),
                  ),
                  Text(
                    [
                      if (track.artist.isNotEmpty) track.artist,
                      if (track.album.isNotEmpty) track.album,
                    ].join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (playing)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: PlayingBars(),
              ),
            if (track.durationMs > 0)
              Text(
                formatDuration(track.duration),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class SwEmptyState extends StatelessWidget {
  const SwEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: SwColors.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    );
  }
}
