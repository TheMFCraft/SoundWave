import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../app_shell.dart';
import '../library/collection_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/artwork.dart';
import '../widgets/context_sheet.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Mood _mood = Mood.forYou;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final player = context.watch<PlayerController>();
    final featured = library.featured;
    final recents = library.recents();
    final mixes = library.topMixes();
    final moodTracks = library.moodTracks(_mood);

    return AdaptivePage(
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          const SoundWaveHeader(),
          if (library.tracks.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: library.scanning
                  ? const Center(child: CircularProgressIndicator())
                  : SwEmptyState(
                      icon: Icons.library_music_outlined,
                      title: l10n.noMusicTitle,
                      message: l10n.noMusicBody,
                      action: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(l10n.importMusic),
                      ),
                    ),
            )
          else ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _margin(context),
                8,
                _margin(context),
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _HeroCard(
                  track: featured!,
                  subtitle: featured.artist.isEmpty
                      ? l10n.unknownArtist
                      : featured.artist,
                  badge: l10n.featuredPremiere,
                  onPlay: () {
                    player.playTracks(
                      moodTracks.isEmpty ? library.tracks : moodTracks,
                      startIndex: 0,
                      context: QueueContext(
                        kind: QueueKind.mix,
                        name: l10n.moodForYou,
                      ),
                    );
                  },
                  onLongPress: () {
                    showTrackContext(
                      context,
                      track: featured,
                      queue: moodTracks.isEmpty ? library.tracks : moodTracks,
                      playContext: QueueContext(
                        kind: QueueKind.mix,
                        name: l10n.moodForYou,
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: SwSpacing.lg),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: _margin(context)),
                    children: [
                      for (final mood in Mood.values) ...[
                        _MoodChip(
                          label: _moodLabel(l10n, mood),
                          selected: _mood == mood,
                          onTap: () => setState(() => _mood = mood),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (recents.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  _margin(context),
                  SwSpacing.lg,
                  _margin(context),
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _Section(
                    title: l10n.jumpBackIn,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recents.take(8).length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.sizeOf(context).width >= 840
                            ? 4
                            : 2,
                        mainAxisExtent: 72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final track = recents[index];
                        return _RecentTile(
                          track: track,
                          onTap: () {
                            player.playTracks(
                              recents,
                              startIndex: index,
                              context: QueueContext(
                                kind: QueueKind.mix,
                                name: l10n.jumpBackIn,
                              ),
                            );
                          },
                          onLongPress: () {
                            showTrackContext(
                              context,
                              track: track,
                              queue: recents,
                              index: index,
                              playContext: QueueContext(
                                kind: QueueKind.mix,
                                name: l10n.jumpBackIn,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (mixes.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _margin(context),
                    SwSpacing.lg,
                    0,
                    0,
                  ),
                  child: _Section(
                    title: l10n.yourTopMixes,
                    child: SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(right: _margin(context)),
                        itemCount: mixes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final mix = mixes[index];
                          return _MixCard(
                            name: mix.name,
                            subtitle: mix.tracks
                                .take(3)
                                .map((t) => t.title)
                                .join(', '),
                            track: mix.tracks.first,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CollectionScreen.artist(mix),
                                ),
                              );
                            },
                            onPlay: () {
                              player.playTracks(
                                mix.tracks,
                                context: QueueContext(
                                  kind: QueueKind.mix,
                                  name: mix.name,
                                ),
                              );
                            },
                            onLongPress: () {
                              showCollectionContext(
                                context,
                                title: mix.name,
                                cover: mix.tracks.first,
                                tracks: mix.tracks,
                                playContext: QueueContext(
                                  kind: QueueKind.mix,
                                  name: mix.name,
                                ),
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          CollectionScreen.artist(mix),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _margin(context),
                SwSpacing.lg,
                _margin(context),
                120,
              ),
              sliver: SliverList.builder(
                itemCount: moodTracks.take(12).length,
                itemBuilder: (context, index) {
                  final track = moodTracks[index];
                  return TrackTile(
                    track: track,
                    playing: player.current?.id == track.id,
                    contextQueue: moodTracks,
                    contextIndex: index,
                    playContext: QueueContext(
                      kind: QueueKind.mix,
                      name: _moodLabel(l10n, _mood),
                    ),
                    onTap: () {
                      player.playTracks(
                        moodTracks,
                        startIndex: index,
                        context: QueueContext(
                          kind: QueueKind.mix,
                          name: _moodLabel(l10n, _mood),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _margin(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 840
        ? SwSpacing.screenMarginMedium
        : SwSpacing.screenMarginCompact;
  }

  String _moodLabel(AppLocalizations l10n, Mood mood) {
    return switch (mood) {
      Mood.forYou => l10n.moodForYou,
      Mood.focus => l10n.moodFocus,
      Mood.workout => l10n.moodWorkout,
      Mood.relax => l10n.moodRelax,
      Mood.night => l10n.moodNight,
    };
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.track,
    required this.subtitle,
    required this.badge,
    required this.onPlay,
    this.onLongPress,
  });

  final Track track;
  final String subtitle;
  final String badge;
  final VoidCallback onPlay;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: MediaQuery.sizeOf(context).width >= 840 ? 21 / 9 : 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Artwork(track: track, borderRadius: 0),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC121212)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: SwColors.secondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: SwColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    NeonLikePlay(onPressed: onPlay),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeonLikePlay extends StatelessWidget {
  const NeonLikePlay({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.primary,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: SwColors.primary,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.play_arrow_rounded,
            color: SwColors.onPrimary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: SwColors.primary,
      labelStyle: TextStyle(
        color: selected ? SwColors.onPrimary : SwColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.track,
    required this.onTap,
    this.onLongPress,
  });

  final Track track;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Artwork(track: track, size: 72, borderRadius: 0),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                track.album.isNotEmpty ? track.album : track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _MixCard extends StatelessWidget {
  const _MixCard({
    required this.name,
    required this.subtitle,
    required this.track,
    required this.onTap,
    required this.onPlay,
    this.onLongPress,
  });

  final String name;
  final String subtitle;
  final Track track;
  final VoidCallback onTap;
  final VoidCallback onPlay;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Artwork(track: track, size: 168, borderRadius: 12),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Material(
                    color: SwColors.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onPlay,
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: SwColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: SwColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
