import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/spacing.dart';
import '../app_shell.dart';
import '../widgets/artwork.dart';
import '../widgets/track_tile.dart';
import 'playlist_editor_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final player = context.watch<PlayerController>();
    final playlist = library.playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.queueEmpty)));
    }
    final tracks = library.tracksForPlaylist(playlist);
    final cover = playlist.coverPath != null
        ? null
        : (tracks.isEmpty ? null : tracks.first);

    return Scaffold(
      body: AdaptivePage(
        padding: EdgeInsets.zero,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(playlist.name),
              actions: [
                IconButton(
                  tooltip: l10n.editPlaylist,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PlaylistEditorScreen(playlistId: playlist.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: _m(context)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Artwork(track: cover, path: playlist.coverPath, size: 220, borderRadius: 16),
                    const SizedBox(height: 16),
                    Text(playlist.name, style: Theme.of(context).textTheme.headlineMedium),
                    if (playlist.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(playlist.description, textAlign: TextAlign.center),
                      ),
                    Text(l10n.tracksCount(tracks.length)),
                    const SizedBox(height: 16),
                    if (tracks.isNotEmpty)
                      FilledButton.icon(
                        onPressed: () {
                          player.playTracks(
                            tracks,
                            context: QueueContext(kind: QueueKind.playlist, name: playlist.name),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(l10n.playAll),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_m(context), 0, _m(context), 120),
              sliver: SliverList.builder(
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return TrackTile(
                    track: track,
                    playing: player.current?.id == track.id,
                    contextQueue: tracks,
                    contextIndex: index,
                    playContext: QueueContext(kind: QueueKind.playlist, name: playlist.name),
                    onRemoveFromPlaylist: () {
                      library.savePlaylist(
                        playlist.copyWith(
                          trackIds: playlist.trackIds.where((id) => id != track.id).toList(),
                        ),
                      );
                    },
                    onTap: () {
                      player.playTracks(
                        tracks,
                        startIndex: index,
                        context: QueueContext(kind: QueueKind.playlist, name: playlist.name),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _m(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840 ? SwSpacing.screenMarginMedium : SwSpacing.screenMarginCompact;
}
