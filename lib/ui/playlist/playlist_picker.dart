import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';

Future<void> showPlaylistPicker(BuildContext context, String trackId) async {
  final library = context.read<LibraryController>();
  final l10n = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.addToPlaylist)),
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: Text(l10n.newPlaylist),
              onTap: () async {
                final playlist = await library.createPlaylist(name: l10n.newPlaylist);
                await library.addToPlaylist(playlist.id, trackId);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final playlist in library.playlists)
                    ListTile(
                      title: Text(playlist.name),
                      onTap: () async {
                        await library.addToPlaylist(playlist.id, trackId);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.addedToPlaylist(playlist.name))),
                          );
                        }
                      },
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
