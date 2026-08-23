import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../library/collection_screen.dart';
import '../playlist/playlist_picker.dart';
import 'artwork.dart';

Future<void> showTrackContext(
  BuildContext context, {
  required Track track,
  List<Track>? queue,
  int index = 0,
  QueueContext? playContext,
  VoidCallback? onRemoveFromPlaylist,
  VoidCallback? onRemoveFromQueue,
}) {
  HapticFeedback.mediumImpact();
  final library = context.read<LibraryController>();
  final player = context.read<PlayerController>();
  final live = library.trackById(track.id) ?? track;
  final playList = queue == null || queue.isEmpty ? [live] : queue;
  final startIndex = queue == null ? 0 : index.clamp(0, playList.length - 1);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SwColors.surfaceContainer,
    builder: (sheet) {
      final l10n = AppLocalizations.of(sheet);
      final liked = (library.trackById(live.id) ?? live).liked;
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Artwork(track: live, size: 56, borderRadius: 10),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              live.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheet).textTheme.titleMedium,
                            ),
                            Text(
                              [
                                if (live.artist.isNotEmpty) live.artist,
                                if (live.album.isNotEmpty) live.album,
                              ].join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(sheet).textTheme.bodyMedium
                                  ?.copyWith(color: SwColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _action(
                  sheet,
                  icon: Icons.play_arrow_rounded,
                  label: l10n.play,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.playTracks(
                      playList,
                      startIndex: startIndex,
                      context:
                          playContext ??
                          QueueContext(kind: QueueKind.songs, name: live.title),
                    );
                  },
                ),
                _action(
                  sheet,
                  icon: Icons.playlist_play_rounded,
                  label: l10n.playNext,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.addNext(live);
                    _snack(context, l10n.playingNext);
                  },
                ),
                _action(
                  sheet,
                  icon: Icons.queue_music_rounded,
                  label: l10n.addToQueue,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.addToQueue(live);
                    _snack(context, l10n.addedToQueue);
                  },
                ),
                _action(
                  sheet,
                  icon: liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: liked ? l10n.unlike : l10n.like,
                  color: liked ? SwColors.primary : null,
                  onTap: () {
                    Navigator.pop(sheet);
                    library.toggleLike(live.id);
                  },
                ),
                _action(
                  sheet,
                  icon: Icons.playlist_add_rounded,
                  label: l10n.addToPlaylist,
                  onTap: () {
                    Navigator.pop(sheet);
                    showPlaylistPicker(context, live.id);
                  },
                ),
                _action(
                  sheet,
                  icon: Icons.album_outlined,
                  label: l10n.goToAlbum,
                  onTap: () {
                    Navigator.pop(sheet);
                    final albums = library.albums.where(
                      (album) => album.key == live.albumKey,
                    );
                    if (albums.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CollectionScreen.album(albums.first),
                      ),
                    );
                  },
                ),
                _action(
                  sheet,
                  icon: Icons.person_outline_rounded,
                  label: l10n.goToArtist,
                  onTap: () {
                    Navigator.pop(sheet);
                    final name = live.artist.isEmpty
                        ? 'Unknown artist'
                        : live.artist;
                    final artists = library.artists.where(
                      (artist) => artist.name == name,
                    );
                    if (artists.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CollectionScreen.artist(artists.first),
                      ),
                    );
                  },
                ),
                if (onRemoveFromPlaylist != null)
                  _action(
                    sheet,
                    icon: Icons.remove_circle_outline_rounded,
                    label: l10n.removeFromPlaylist,
                    onTap: () {
                      Navigator.pop(sheet);
                      onRemoveFromPlaylist();
                    },
                  ),
                if (onRemoveFromQueue != null)
                  _action(
                    sheet,
                    icon: Icons.playlist_remove_rounded,
                    label: l10n.removeFromQueue,
                    onTap: () {
                      Navigator.pop(sheet);
                      onRemoveFromQueue();
                    },
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showCollectionContext(
  BuildContext context, {
  required String title,
  String? subtitle,
  Track? cover,
  required List<Track> tracks,
  required QueueContext playContext,
  VoidCallback? onOpen,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  HapticFeedback.mediumImpact();
  final player = context.read<PlayerController>();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: SwColors.surfaceContainer,
    builder: (sheet) {
      final l10n = AppLocalizations.of(sheet);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Artwork(track: cover, size: 56, borderRadius: 10),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheet).textTheme.titleMedium,
                          ),
                          Text(
                            subtitle ?? l10n.tracksCount(tracks.length),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(sheet).textTheme.bodyMedium
                                ?.copyWith(color: SwColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (onOpen != null)
                _action(
                  sheet,
                  icon: Icons.open_in_new_rounded,
                  label: l10n.open,
                  onTap: () {
                    Navigator.pop(sheet);
                    onOpen();
                  },
                ),
              if (tracks.isNotEmpty)
                _action(
                  sheet,
                  icon: Icons.play_arrow_rounded,
                  label: l10n.playAll,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.playTracks(tracks, context: playContext);
                  },
                ),
              if (tracks.isNotEmpty)
                _action(
                  sheet,
                  icon: Icons.shuffle_rounded,
                  label: l10n.shuffleAll,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.playTracks(
                      tracks,
                      shuffled: true,
                      context: playContext,
                    );
                  },
                ),
              if (tracks.isNotEmpty)
                _action(
                  sheet,
                  icon: Icons.queue_music_rounded,
                  label: l10n.addToQueue,
                  onTap: () {
                    Navigator.pop(sheet);
                    player.addAllToQueue(tracks);
                    _snack(context, l10n.addedToQueue);
                  },
                ),
              if (onEdit != null)
                _action(
                  sheet,
                  icon: Icons.edit_outlined,
                  label: l10n.editPlaylist,
                  onTap: () {
                    Navigator.pop(sheet);
                    onEdit();
                  },
                ),
              if (onDelete != null)
                _action(
                  sheet,
                  icon: Icons.delete_outline_rounded,
                  label: l10n.delete,
                  color: SwColors.error,
                  onTap: () {
                    Navigator.pop(sheet);
                    onDelete();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _action(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? SwColors.onSurface),
    title: Text(
      label,
      style: TextStyle(
        color: color ?? SwColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: onTap,
  );
}

void _snack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
