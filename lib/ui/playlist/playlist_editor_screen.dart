import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../theme/colors.dart';
import '../app_shell.dart';
import '../widgets/artwork.dart';
import '../widgets/track_tile.dart';

class PlaylistEditorScreen extends StatefulWidget {
  const PlaylistEditorScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  State<PlaylistEditorScreen> createState() => _PlaylistEditorScreenState();
}

class _PlaylistEditorScreenState extends State<PlaylistEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late bool _showOnHome;
  String? _coverPath;
  late List<String> _trackIds;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _description = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final playlist = context.read<LibraryController>().playlists.where((p) => p.id == widget.playlistId).firstOrNull;
    if (playlist == null) return;
    _name.text = playlist.name;
    _description.text = playlist.description;
    _showOnHome = playlist.showOnHome;
    _coverPath = playlist.coverPath;
    _trackIds = [...playlist.trackIds];
    _ready = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();
    final playlist = library.playlists.where((p) => p.id == widget.playlistId).firstOrNull;
    if (playlist == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final tracks = [
      for (final id in _trackIds)
        if (library.trackById(id) != null) library.trackById(id)!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editPlaylist),
        actions: [
          TextButton(
            onPressed: () async {
              await library.savePlaylist(
                playlist.copyWith(
                  name: _name.text.trim().isEmpty ? l10n.newPlaylist : _name.text.trim(),
                  description: _description.text.trim(),
                  showOnHome: _showOnHome,
                  coverPath: _coverPath,
                  trackIds: _trackIds,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
      body: AdaptivePage(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120, top: 12),
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  final path = result?.files.single.path;
                  if (path != null) setState(() => _coverPath = path);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Artwork(
                      path: _coverPath,
                      track: tracks.isEmpty ? null : tracks.first,
                      size: 220,
                      borderRadius: 16,
                    ),
                    ColoredBox(
                      color: Colors.black45,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: SwColors.primary),
                            Text(l10n.changeImage, style: const TextStyle(color: SwColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.playlistTitle.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: InputDecoration(hintText: l10n.playlistTitleHint)),
            const SizedBox(height: 16),
            Text(l10n.playlistDescription.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.playlistDescriptionHint),
            ),
            const SizedBox(height: 16),
            Text(l10n.privacy.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10n.privacyPublic),
                    selected: _showOnHome,
                    onSelected: (_) => setState(() => _showOnHome = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text(l10n.privacyPrivate),
                    selected: !_showOnHome,
                    onSelected: (_) => setState(() => _showOnHome = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Text(l10n.tracksCount(tracks.length), style: Theme.of(context).textTheme.titleMedium)),
                TextButton.icon(
                  onPressed: () => _addSongs(context, library),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.addSongs),
                ),
              ],
            ),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tracks.length,
              onReorderItem: (from, to) {
                setState(() {
                  final id = _trackIds.removeAt(from);
                  _trackIds.insert(to, id);
                });
              },
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Material(
                  key: ValueKey(track.id),
                  color: Colors.transparent,
                  child: TrackTile(
                    track: track,
                    onTap: () {},
                    leading: const Icon(Icons.drag_indicator_rounded),
                    trailing: IconButton(
                      onPressed: () => setState(() => _trackIds.remove(track.id)),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _addSongs(context, library),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(Icons.search_rounded),
                    const SizedBox(height: 8),
                    Text(l10n.findMusic),
                    Text(l10n.findMusicBody, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.deletePlaylistTitle),
                    content: Text(l10n.deletePlaylistBody(playlist.name)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.delete)),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await library.deletePlaylist(playlist.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text(l10n.delete, style: const TextStyle(color: SwColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSongs(BuildContext context, LibraryController library) async {
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var query = '';
        return StatefulBuilder(
          builder: (context, setModal) {
            final results = library.tracks.where((t) {
              if (_trackIds.contains(t.id)) return false;
              if (query.trim().isEmpty) return true;
              return t.searchBlob.contains(query.trim().toLowerCase());
            }).toList();
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              builder: (context, controller) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(hintText: l10n.searchHint, prefixIcon: const Icon(Icons.search_rounded)),
                        onChanged: (value) => setModal(() => query = value),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final track = results[index];
                          return TrackTile(
                            track: track,
                            enableContextMenu: false,
                            onTap: () => Navigator.pop(context, track.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    if (selected != null) setState(() => _trackIds.add(selected));
  }
}
