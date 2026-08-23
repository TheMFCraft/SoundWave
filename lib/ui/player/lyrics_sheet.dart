import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../theme/colors.dart';

Future<void> showLyricsSheet(BuildContext context, Track track) {
  final library = context.read<LibraryController>();
  if (track.lyrics.trim().isEmpty) {
    unawaited(library.ensureLyrics(track.id));
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SwColors.surfaceContainer,
    builder: (context) => LyricsSheet(trackId: track.id, fallback: track),
  );
}

class LyricsSheet extends StatelessWidget {
  const LyricsSheet({super.key, required this.trackId, required this.fallback});

  final String trackId;
  final Track fallback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final live = library.trackById(trackId) ?? fallback;
    final fetching = library.isFetchingLyrics(live.id);
    final lyrics = live.lyrics.trim();
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, controller) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 4, 24, 20 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.lyrics, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text(
                live.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (live.artist.isNotEmpty)
                Text(
                  live.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SwColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: fetching && lyrics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              l10n.fetchingLyrics,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SwColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : lyrics.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noLyrics,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SwColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                            ),
                          )
                        : ListView(
                            controller: controller,
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              Text(
                                lyrics,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontSize: 22,
                                      height: 1.75,
                                      fontWeight: FontWeight.w600,
                                      color: SwColors.onSurface,
                                    ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
