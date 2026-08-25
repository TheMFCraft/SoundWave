import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../state/library_controller.dart';
import '../../theme/colors.dart';
import '../app_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final library = context.watch<LibraryController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: AdaptivePage(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48, top: 8),
          children: [
            Text(l10n.importMusic, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: library.scanning
                  ? null
                  : () async {
                      final count = await library.importFolder();
                      if (!context.mounted) return;
                      _toast(context, l10n, count);
                    },
              icon: const Icon(Icons.folder_open_rounded),
              label: Text(l10n.importFolder),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: library.scanning
                  ? null
                  : () async {
                      final count = await library.importFiles();
                      if (!context.mounted) return;
                      _toast(context, l10n, count);
                    },
              icon: const Icon(Icons.audio_file_outlined),
              label: Text(l10n.importFiles),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: library.scanning
                  ? null
                  : () async {
                      final count = await library.scanDefaultMusic();
                      if (!context.mounted) return;
                      if (count < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.permissionDenied)));
                        return;
                      }
                      _toast(context, l10n, count);
                    },
              icon: const Icon(Icons.library_music_outlined),
              label: Text(library.scanning ? l10n.scanning : l10n.scanDevice),
            ),
            const SizedBox(height: 24),
            Text(l10n.folders, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (library.settings.folders.isEmpty)
              Text(l10n.noFolders, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant))
            else
              for (final folder in library.settings.folders)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    tooltip: l10n.removeFolder,
                    onPressed: () => library.removeFolder(folder),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: library.scanning ? null : library.rescan, child: Text(l10n.rescan)),
            ),
            const SizedBox(height: 16),
            Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<AppLanguage>(
              segments: [
                ButtonSegment(value: AppLanguage.system, label: Text(l10n.languageSystem)),
                ButtonSegment(value: AppLanguage.en, label: Text(l10n.languageEnglish)),
                ButtonSegment(value: AppLanguage.de, label: Text(l10n.languageGerman)),
              ],
              selected: {library.settings.language},
              onSelectionChanged: (value) {
                library.updateSettings(library.settings.copyWith(language: value.first));
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.clearHistory),
              onTap: library.clearSearches,
            ),
            const Divider(),
            Text(l10n.about, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.aboutBody, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(l10n.version('1.1.3'), style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, AppLocalizations l10n, int count) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.importedCount(count))));
  }
}
