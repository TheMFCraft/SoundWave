import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../player/now_playing_screen.dart';
import 'artwork.dart';
import 'context_sheet.dart';
import 'playing_bars.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = context.watch<PlayerController>();
    final track = player.current;
    if (track == null) return const SizedBox.shrink();

    return Material(
      color: const Color(0xFF0A0A0A),
      child: InkWell(
        onTap: () => openNowPlaying(context),
        onLongPress: () => showTrackContext(
          context,
          track: track,
          queue: player.queue,
          index: player.index,
          playContext: player.context,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              Artwork(track: track, size: 44, borderRadius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                    ),
                    Text(
                      track.artist.isEmpty ? l10n.unknownArtist : track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SwColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (player.playing) const PlayingBars(),
              IconButton(
                tooltip: player.playing ? l10n.pause : l10n.play,
                onPressed: player.playPause,
                icon: Icon(player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
              IconButton(
                tooltip: l10n.next,
                onPressed: player.next,
                icon: const Icon(Icons.skip_next_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> openNowPlaying(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => const NowPlayingScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _NowPlayingSlide(animation: animation, child: child);
      },
    ),
  );
}

class _NowPlayingSlide extends StatefulWidget {
  const _NowPlayingSlide({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  State<_NowPlayingSlide> createState() => _NowPlayingSlideState();
}

class _NowPlayingSlideState extends State<_NowPlayingSlide> {
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: ColoredBox(
        color: SwColors.background,
        child: widget.child,
      ),
    );
  }
}
