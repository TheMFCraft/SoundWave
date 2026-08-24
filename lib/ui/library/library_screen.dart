import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../jam/jam.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../app_shell.dart';
import '../playlist/playlist_detail_screen.dart';
import '../playlist/playlist_editor_screen.dart';
import '../widgets/artwork.dart';
import '../widgets/context_sheet.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';
import 'collection_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryFilter _filter = LibraryFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final player = context.watch<PlayerController>();
    final jam = context.watch<JamController>();
    final otherLibraries = [
      for (final lib in jam.remoteLibraries)
        if (lib.memberId != jam.memberId) lib,
    ];
    if (_filter == LibraryFilter.jam && !jam.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _filter = LibraryFilter.all);
      });
    }

    return AdaptivePage(
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          const SoundWaveHeader(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(_m(context), 8, _m(context), 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.yourLibrary,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.newPlaylist,
                    onPressed: () async {
                      final playlist = await library.createPlaylist(
                        name: l10n.newPlaylist,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              PlaylistEditorScreen(playlistId: playlist.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: _m(context),
                  vertical: 8,
                ),
                children: [
                  _FilterChip(
                    label: l10n.playlists,
                    selected: _filter == LibraryFilter.playlists,
                    onTap: () =>
                        setState(() => _filter = LibraryFilter.playlists),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.artists,
                    selected: _filter == LibraryFilter.artists,
                    onTap: () =>
                        setState(() => _filter = LibraryFilter.artists),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.albums,
                    selected: _filter == LibraryFilter.albums,
                    onTap: () => setState(() => _filter = LibraryFilter.albums),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.songs,
                    selected: _filter == LibraryFilter.all,
                    onTap: () => setState(() => _filter = LibraryFilter.all),
                  ),
                  if (jam.isActive) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.jamLibraryChip,
                      selected: _filter == LibraryFilter.jam,
                      onTap: () => setState(() => _filter = LibraryFilter.jam),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_filter == LibraryFilter.jam)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_m(context), 8, _m(context), 120),
              sliver: _jamBody(context, jam, player, l10n, otherLibraries),
            )
          else if (library.tracks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: library.scanning
                  ? const Center(child: CircularProgressIndicator())
                  : SwEmptyState(
                      icon: Icons.library_music_outlined,
                      title: l10n.noMusicTitle,
                      message: l10n.noMusicBody,
                    ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_m(context), 8, _m(context), 120),
              sliver: _body(context, library, player, l10n),
            ),
        ],
      ),
    );
  }

  Widget _jamBody(
    BuildContext context,
    JamController jam,
    PlayerController player,
    AppLocalizations l10n,
    List<JamRemoteLibrary> libraries,
  ) {
    if (libraries.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: SwEmptyState(
          icon: Icons.devices_rounded,
          title: l10n.jamLibraryChip,
          message: l10n.jamLibraryEmpty,
        ),
      );
    }
    final rows = <Object>[];
    for (final lib in libraries) {
      rows.add(lib);
      rows.addAll(lib.tracks);
    }
    return SliverList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row is JamRemoteLibrary) {
          return Padding(
            padding: EdgeInsets.fromLTRB(0, index == 0 ? 0 : 16, 0, 8),
            child: Text(
              l10n.jamLibraryFrom(row.memberName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        final track = row as Track;
        JamRemoteLibrary? owner;
        for (final lib in libraries) {
          if (lib.tracks.contains(track)) {
            owner = lib;
            break;
          }
        }
        final queue = owner?.tracks ?? const <Track>[];
        final trackIndex = queue.indexOf(track);
        return TrackTile(
          track: track,
          playing: player.current?.title == track.title &&
              player.current?.artist == track.artist,
          contextQueue: queue,
          contextIndex: trackIndex < 0 ? 0 : trackIndex,
          playContext: QueueContext(
            kind: QueueKind.songs,
            name: owner == null ? l10n.jamLibraryChip : l10n.jamLibraryFrom(owner.memberName),
          ),
          onTap: () {
            player.playTracks(
              queue,
              startIndex: trackIndex < 0 ? 0 : trackIndex,
              context: QueueContext(
                kind: QueueKind.songs,
                name: owner == null
                    ? l10n.jamLibraryChip
                    : l10n.jamLibraryFrom(owner.memberName),
              ),
            );
          },
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    LibraryController library,
    PlayerController player,
    AppLocalizations l10n,
  ) {
    if (_filter == LibraryFilter.all) {
      return SliverList.builder(
        itemCount: 1 + library.sortedTracks(TrackSort.recentlyAdded).length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _LikedTile(count: library.likedTracks.length, l10n: l10n);
          }
          final tracks = library.sortedTracks(TrackSort.recentlyAdded);
          final track = tracks[index - 1];
          return TrackTile(
            track: track,
            playing: player.current?.id == track.id,
            contextQueue: tracks,
            contextIndex: index - 1,
            playContext: QueueContext(
              kind: QueueKind.songs,
              name: l10n.allSongs,
            ),
            onTap: () {
              player.playTracks(
                tracks,
                startIndex: index - 1,
                context: QueueContext(
                  kind: QueueKind.songs,
                  name: l10n.allSongs,
                ),
              );
            },
          );
        },
      );
    }

    if (_filter == LibraryFilter.playlists) {
      final items = [
        _LibraryCardData.liked(l10n.likedSongs, library.likedTracks.length),
        for (final playlist in library.playlists)
          _LibraryCardData.playlist(
            playlist,
            library.tracksForPlaylist(playlist),
          ),
      ];
      return _grid(context, items);
    }

    if (_filter == LibraryFilter.artists) {
      return _grid(context, [
        for (final artist in library.artists) _LibraryCardData.artist(artist),
      ], circle: true);
    }

    return _grid(context, [
      for (final album in library.albums) _LibraryCardData.album(album),
    ]);
  }

  Widget _grid(
    BuildContext context,
    List<_LibraryCardData> items, {
    bool circle = false,
  }) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.sizeOf(context).width >= 1100
            ? 5
            : MediaQuery.sizeOf(context).width >= 840
            ? 4
            : 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.78,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = items[index];
        return _LibraryCard(
          data: item,
          circle: circle && item.kind == _CardKind.artist,
        );
      }, childCount: items.length),
    );
  }

  double _m(BuildContext context) => MediaQuery.sizeOf(context).width >= 840
      ? SwSpacing.screenMarginMedium
      : SwSpacing.screenMarginCompact;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? SwColors.onPrimary : const Color(0xFFF2F0F5),
          fontWeight: FontWeight.w700,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: SwColors.primary,
      backgroundColor: const Color(0xFF2C2C2C),
      side: BorderSide(
        color: selected ? SwColors.primary : const Color(0x33FFFFFF),
      ),
    );
  }
}

class _LikedTile extends StatelessWidget {
  const _LikedTile({required this.count, required this.l10n});

  final int count;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CollectionScreen.likes(title: l10n.likedSongs),
              ),
            );
          },
          onLongPress: () {
            final tracks = context.read<LibraryController>().likedTracks;
            showCollectionContext(
              context,
              title: l10n.likedSongs,
              tracks: tracks,
              playContext: QueueContext(
                kind: QueueKind.likes,
                name: l10n.likedSongs,
              ),
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CollectionScreen.likes(title: l10n.likedSongs),
                  ),
                );
              },
            );
          },
          child: Ink(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: SwColors.neon,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.likedSongs,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  Text(
                    l10n.tracksCount(count),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _CardKind { liked, playlist, artist, album }

class _LibraryCardData {
  _LibraryCardData._(
    this.kind,
    this.title,
    this.subtitle,
    this.track,
    this.onOpen, {
    this.tracks = const [],
    this.playContext,
    this.playlist,
  });

  factory _LibraryCardData.liked(String title, int count) {
    return _LibraryCardData._(
      _CardKind.liked,
      title,
      '',
      null,
      (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CollectionScreen.likes(title: title),
          ),
        );
      },
      playContext: QueueContext(kind: QueueKind.likes, name: title),
    );
  }

  factory _LibraryCardData.playlist(Playlist playlist, List<Track> tracks) {
    return _LibraryCardData._(
      _CardKind.playlist,
      playlist.name,
      '',
      tracks.isEmpty ? null : tracks.first,
      (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
          ),
        );
      },
      tracks: tracks,
      playContext: QueueContext(kind: QueueKind.playlist, name: playlist.name),
      playlist: playlist,
    );
  }

  factory _LibraryCardData.artist(ArtistGroup artist) {
    return _LibraryCardData._(
      _CardKind.artist,
      artist.name,
      '',
      artist.tracks.first,
      (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CollectionScreen.artist(artist),
          ),
        );
      },
      tracks: artist.tracks,
      playContext: QueueContext(kind: QueueKind.songs, name: artist.name),
    );
  }

  factory _LibraryCardData.album(AlbumGroup album) {
    return _LibraryCardData._(
      _CardKind.album,
      album.title,
      album.artist,
      album.representative,
      (context) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CollectionScreen.album(album),
          ),
        );
      },
      tracks: album.tracks,
      playContext: QueueContext(kind: QueueKind.album, name: album.title),
    );
  }

  final _CardKind kind;
  final String title;
  final String subtitle;
  final Track? track;
  final void Function(BuildContext context) onOpen;
  final List<Track> tracks;
  final QueueContext? playContext;
  final Playlist? playlist;
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.data, required this.circle});

  final _LibraryCardData data;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = switch (data.kind) {
      _CardKind.liked => l10n.tracksCount(
        context.read<LibraryController>().likedTracks.length,
      ),
      _CardKind.playlist => l10n.playlistByYou,
      _CardKind.artist => l10n.artistLabel,
      _CardKind.album =>
        data.subtitle.isEmpty ? l10n.albumLabel : data.subtitle,
    };

    return InkWell(
      onTap: () => data.onOpen(context),
      onLongPress: () {
        final tracks = data.kind == _CardKind.liked
            ? context.read<LibraryController>().likedTracks
            : data.tracks;
        final l10n = AppLocalizations.of(context);
        showCollectionContext(
          context,
          title: data.title,
          subtitle: subtitle,
          cover: data.track,
          tracks: tracks,
          playContext:
              data.playContext ??
              QueueContext(kind: QueueKind.songs, name: data.title),
          onOpen: () => data.onOpen(context),
          onEdit: data.playlist == null
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PlaylistEditorScreen(playlistId: data.playlist!.id),
                    ),
                  );
                },
          onDelete: data.playlist == null
              ? null
              : () async {
                  final playlist = data.playlist!;
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.deletePlaylistTitle),
                      content: Text(l10n.deletePlaylistBody(playlist.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await context.read<LibraryController>().deletePlaylist(
                      playlist.id,
                    );
                  }
                },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: circle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (data.kind == _CardKind.liked)
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: SwColors.neon,
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Artwork(
                track: data.track,
                borderRadius: circle ? 999 : 16,
                circle: circle,
              ),
            ),
          const SizedBox(height: 10),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: circle ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFFF6F4F8),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: circle ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB9B3C4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
