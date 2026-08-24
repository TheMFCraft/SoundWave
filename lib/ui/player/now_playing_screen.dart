import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:provider/provider.dart';

import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../jam/jam_screen.dart';
import '../library/collection_screen.dart';
import '../playlist/playlist_picker.dart';
import '../widgets/artwork.dart';
import '../widgets/file_image.dart';
import '../widgets/glass.dart';
import 'lyrics_sheet.dart';
import 'queue_sheet.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  Color _glow = const Color(0x66DAB9FF);
  String? _paletteId;
  String? _palettePath;
  bool _routeReady = false;
  Animation<double>? _routeAnimation;
  AnimationStatusListener? _routeListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation == _routeAnimation) return;
    _detachRoute();
    _routeAnimation = animation;
    if (animation == null || animation.isCompleted) {
      _markReady();
      return;
    }
    _routeListener = (status) {
      if (status == AnimationStatus.completed) _markReady();
    };
    animation.addStatusListener(_routeListener!);
  }

  @override
  void dispose() {
    _detachRoute();
    super.dispose();
  }

  void _detachRoute() {
    if (_routeAnimation != null && _routeListener != null) {
      _routeAnimation!.removeStatusListener(_routeListener!);
    }
    _routeAnimation = null;
    _routeListener = null;
  }

  void _markReady() {
    if (!mounted) return;
    if (_routeReady) {
      _extractPalette(context.read<PlayerController>().current);
      return;
    }
    setState(() => _routeReady = true);
    _extractPalette(context.read<PlayerController>().current);
  }

  Color _glowFromTrack(Track track) {
    final seed = (track.album.isNotEmpty ? track.album : track.title).hashCode;
    return HSVColor.fromAHSV(0.45, (seed % 360).toDouble(), 0.42, 0.55).toColor();
  }

  Future<void> _extractPalette(Track? track) async {
    if (!_routeReady || track == null) return;
    final path = track.artworkPath;
    if (track.id == _paletteId && path == _palettePath) return;
    _paletteId = track.id;
    _palettePath = path;
    final fallback = _glowFromTrack(track);
    if (mounted) setState(() => _glow = fallback);
    if (path == null) return;
    final provider = tryFileImageProvider(path);
    if (provider == null) return;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(provider, width: 48, height: 48),
        maximumColorCount: 4,
        timeout: const Duration(seconds: 2),
      );
      final color = palette.vibrantColor?.color ?? palette.dominantColor?.color;
      if (color != null && mounted && _paletteId == track.id) {
        setState(() => _glow = color.withValues(alpha: 0.45));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = context.watch<PlayerController>();
    final track = player.current;
    if (_routeReady && (track?.id != _paletteId || track?.artworkPath != _palettePath)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _extractPalette(track));
    }
    if (track == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.queueEmpty)),
      );
    }

    final live = context.select<LibraryController, Track>((library) => library.trackById(track.id) ?? track);
    final glow = _routeReady ? _glow : _glowFromTrack(live);
    final fromLabel = switch (player.context.kind) {
      QueueKind.playlist => l10n.playingFromPlaylist,
      QueueKind.album => l10n.playingFromAlbum,
      QueueKind.likes => l10n.likedSongs,
      _ => l10n.playingFromQueue,
    };

    return Scaffold(
      backgroundColor: SwColors.background,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.lerp(SwColors.background, glow, 0.35)!, SwColors.background],
              ),
            ),
          ),
          SafeArea(
            child: AdaptiveInner(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l10n.back,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                fromLabel.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: SwColors.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                player.context.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.more,
                          onPressed: () => _more(context, live),
                          icon: const Icon(Icons.more_vert_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        boxShadow: _routeReady
                            ? [
                                BoxShadow(
                                  color: glow,
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ]
                            : const [],
                      ),
                      child: Artwork(
                        track: live,
                        size: 300,
                        borderRadius: 20,
                        loadMissingArtwork: _routeReady,
                        decodeSize: _routeReady ? null : 96,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(live.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineMedium),
                              Text(
                                live.artist.isEmpty ? l10n.unknownArtist : live.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: SwColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: live.liked ? l10n.unlike : l10n.like,
                          onPressed: () => context.read<LibraryController>().toggleLike(live.id),
                          icon: Icon(
                            live.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: live.liked ? SwColors.primary : SwColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StreamBuilder<Duration>(
                      stream: player.positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final total = player.duration.inMilliseconds <= 0 ? live.duration : player.duration;
                        final max = total.inMilliseconds <= 0 ? 1.0 : total.inMilliseconds.toDouble();
                        final value = position.inMilliseconds.toDouble().clamp(0.0, max);
                        return Column(
                          children: [
                            Slider(
                              value: value,
                              max: max,
                              onChanged: (value) => player.seek(Duration(milliseconds: value.round())),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatDuration(position), style: Theme.of(context).textTheme.labelSmall),
                                  Text(formatDuration(total), style: Theme.of(context).textTheme.labelSmall),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: l10n.shuffle,
                          onPressed: player.toggleShuffle,
                          color: player.shuffle ? SwColors.secondary : SwColors.onSurfaceVariant,
                          icon: const Icon(Icons.shuffle_rounded),
                        ),
                        IconButton(
                          tooltip: l10n.previous,
                          onPressed: player.previous,
                          icon: const Icon(Icons.skip_previous_rounded, size: 40),
                        ),
                        NeonPlayButton(playing: player.playing, onPressed: player.playPause),
                        IconButton(
                          tooltip: l10n.next,
                          onPressed: player.next,
                          icon: const Icon(Icons.skip_next_rounded, size: 40),
                        ),
                        IconButton(
                          tooltip: player.repeat == PlayRepeat.one ? l10n.repeatOne : l10n.repeat,
                          onPressed: player.cycleRepeat,
                          color: player.repeat == PlayRepeat.off ? SwColors.onSurfaceVariant : SwColors.secondary,
                          icon: Icon(player.repeat == PlayRepeat.one ? Icons.repeat_one_rounded : Icons.repeat_rounded),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => showLyricsSheet(context, live),
                          icon: const Icon(Icons.lyrics_outlined, size: 20),
                          label: Text(l10n.lyrics),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.sleepTimer,
                          onPressed: () => _sleep(context),
                          icon: Icon(
                            Icons.bedtime_outlined,
                            color: player.sleepUntil != null || player.sleepEndOfTrack
                                ? SwColors.secondary
                                : SwColors.onSurfaceVariant,
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.jamTitle,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const JamScreen()),
                            );
                          },
                          icon: const Icon(Icons.graphic_eq_rounded),
                        ),
                        IconButton(
                          tooltip: l10n.queue,
                          onPressed: () => showQueueSheet(context),
                          icon: const Icon(Icons.queue_music_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sleep(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = context.read<PlayerController>();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.sleepTimer)),
              ListTile(
                title: Text(l10n.sleepOff),
                onTap: () {
                  player.setSleepTimer();
                  Navigator.pop(context);
                },
              ),
              for (final minutes in [5, 15, 30, 45, 60])
                ListTile(
                  title: Text(l10n.sleepMinutes(minutes)),
                  onTap: () {
                    player.setSleepTimer(duration: Duration(minutes: minutes));
                    Navigator.pop(context);
                  },
                ),
              ListTile(
                title: Text(l10n.sleepEndOfTrack),
                onTap: () {
                  player.setSleepTimer(endOfTrack: true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _more(BuildContext context, Track track) {
    final l10n = AppLocalizations.of(context);
    final library = context.read<LibraryController>();
    final player = context.read<PlayerController>();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded),
                title: Text(l10n.addToPlaylist),
                onTap: () {
                  Navigator.pop(context);
                  showPlaylistPicker(context, track.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.album_outlined),
                title: Text(l10n.goToAlbum),
                onTap: () {
                  Navigator.pop(context);
                  final albums = library.albums.where((a) => a.key == track.albumKey);
                  if (albums.isEmpty) return;
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CollectionScreen.album(albums.first)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(l10n.goToArtist),
                onTap: () {
                  Navigator.pop(context);
                  final artists = library.artists.where((a) => a.name == (track.artist.isEmpty ? 'Unknown artist' : track.artist));
                  if (artists.isEmpty) return;
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CollectionScreen.artist(artists.first)));
                },
              ),
              ListTile(
                title: Text(l10n.playbackSpeed),
                trailing: Text('${player.speed}x'),
                onTap: () {
                  Navigator.pop(context);
                  _speed(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _speed(BuildContext context) {
    final player = context.read<PlayerController>();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final speed in [0.8, 1.0, 1.25, 1.5])
                ListTile(
                  title: Text('${speed}x'),
                  selected: player.speed == speed,
                  onTap: () {
                    player.setSpeed(speed);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class AdaptiveInner extends StatelessWidget {
  const AdaptiveInner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: child,
      ),
    );
  }
}
