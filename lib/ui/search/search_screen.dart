import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/catalog.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../state/player_controller.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../app_shell.dart';
import '../library/collection_screen.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final player = context.watch<PlayerController>();
    final results = searchTracks(library.tracks, _query);
    final genres = [
      (l10n.genrePop, 'pop', const Color(0xFFBB86FC)),
      (l10n.genreRock, 'rock', const Color(0xFFEC7D90)),
      (l10n.genreHipHop, 'hiphop', const Color(0xFF00D8C4)),
      (l10n.genreElectronic, 'electronic', const Color(0xFF7743B5)),
      (l10n.genreClassical, 'classical', const Color(0xFF46F5E0)),
      (l10n.genreJazz, 'jazz', const Color(0xFFDAB9FF)),
    ];

    return AdaptivePage(
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          const SoundWaveHeader(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(_m(context), 8, _m(context), 0),
            sliver: SliverToBoxAdapter(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: (value) => library.addSearch(value),
              ),
            ),
          ),
          if (_query.isEmpty) ...[
            if (library.settings.recentSearches.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(_m(context), SwSpacing.lg, _m(context), 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.recentSearches, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final item in library.settings.recentSearches)
                            ActionChip(
                              avatar: const Icon(Icons.history_rounded, size: 16),
                              label: Text(item),
                              onPressed: () {
                                _controller.text = item;
                                setState(() => _query = item);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_m(context), SwSpacing.lg, _m(context), 120),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.browseAll, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.sizeOf(context).width >= 840 ? 4 : 2,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        for (final genre in genres)
                          _GenreCard(
                            label: genre.$1,
                            color: genre.$3,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CollectionScreen.genre(
                                    title: genre.$1,
                                    tracks: library.tracks.where((t) => trackMatchesGenre(t, genre.$2)).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else if (results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SwEmptyState(
                icon: Icons.search_off_rounded,
                title: l10n.emptySearchTitle,
                message: l10n.emptySearchBody,
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_m(context), SwSpacing.md, _m(context), 120),
              sliver: SliverList.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final track = results[index];
                  return TrackTile(
                    track: track,
                    playing: player.current?.id == track.id,
                    contextQueue: results,
                    contextIndex: index,
                    playContext: QueueContext(kind: QueueKind.songs, name: l10n.results),
                    onTap: () {
                      library.addSearch(_query);
                      player.playTracks(
                        results,
                        startIndex: index,
                        context: QueueContext(kind: QueueKind.songs, name: l10n.results),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  double _m(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840 ? SwSpacing.screenMarginMedium : SwSpacing.screenMarginCompact;
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SwColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.85), SwColors.background],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(label, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
        ),
      ),
    );
  }
}
