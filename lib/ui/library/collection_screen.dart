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

class CollectionScreen extends StatelessWidget {
  const CollectionScreen._({
    required this.title,
    required this.kind,
    required this.tracksBuilder,
    this.heroTrack,
    this.showLike = true,
  });

  factory CollectionScreen.album(AlbumGroup album) {
    return CollectionScreen._(
      title: album.title,
      kind: QueueKind.album,
      heroTrack: album.representative,
      tracksBuilder: (_) => album.tracks,
    );
  }

  factory CollectionScreen.artist(ArtistGroup artist) {
    return CollectionScreen._(
      title: artist.name,
      kind: QueueKind.songs,
      heroTrack: artist.tracks.first,
      tracksBuilder: (_) => artist.tracks,
    );
  }

  factory CollectionScreen.genre({required String title, required List<Track> tracks}) {
    return CollectionScreen._(
      title: title,
      kind: QueueKind.mix,
      heroTrack: tracks.isEmpty ? null : tracks.first,
      tracksBuilder: (_) => tracks,
    );
  }

  factory CollectionScreen.remote({required String title, required List<Track> tracks}) {
    return CollectionScreen._(
      title: title,
      kind: QueueKind.songs,
      heroTrack: tracks.isEmpty ? null : tracks.first,
      tracksBuilder: (_) => tracks,
      showLike: false,
    );
  }

  factory CollectionScreen.likes({required String title}) {
    return CollectionScreen._(
      title: title,
      kind: QueueKind.likes,
      tracksBuilder: (library) => library.likedTracks,
    );
  }

  final String title;
  final QueueKind kind;
  final Track? heroTrack;
  final List<Track> Function(LibraryController library) tracksBuilder;
  final bool showLike;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final player = context.watch<PlayerController>();
    final tracks = tracksBuilder(library);
    final cover = heroTrack ?? (tracks.isEmpty ? null : tracks.first);

    return Scaffold(
      body: AdaptivePage(
        padding: EdgeInsets.zero,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(title),
              actions: [
                if (tracks.isNotEmpty)
                  IconButton(
                    tooltip: l10n.shuffleAll,
                    onPressed: () {
                      player.playTracks(
                        tracks,
                        shuffled: true,
                        context: QueueContext(kind: kind, name: title),
                      );
                    },
                    icon: const Icon(Icons.shuffle_rounded),
                  ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: _m(context)),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (cover != null) Artwork(track: cover, size: 220, borderRadius: 16),
                    const SizedBox(height: 16),
                    Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    Text(l10n.tracksCount(tracks.length), style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    if (tracks.isNotEmpty)
                      FilledButton.icon(
                        onPressed: () {
                          player.playTracks(tracks, context: QueueContext(kind: kind, name: title));
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
                    playContext: QueueContext(kind: kind, name: title),
                    onTap: () {
                      player.playTracks(
                        tracks,
                        startIndex: index,
                        context: QueueContext(kind: kind, name: title),
                      );
                    },
                    trailing: showLike
                        ? IconButton(
                            onPressed: () => library.toggleLike(track.id),
                            icon: Icon(
                              track.liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                            ),
                          )
                        : null,
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
