import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/local_fs.dart';
import '../../jam/jam.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../app_shell.dart';
import '../library/collection_screen.dart';

class JamScreen extends StatefulWidget {
  const JamScreen({super.key});

  @override
  State<JamScreen> createState() => _JamScreenState();
}

class _JamScreenState extends State<JamScreen> {
  final _host = TextEditingController();
  final _pin = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JamController>().startBrowsing();
    });
  }

  @override
  void dispose() {
    _host.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final jam = context.watch<JamController>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.jamTitle)),
      body: AdaptivePage(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48, top: 8),
          children: [
            Text(l10n.jamBody, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant)),
            if (jam.error != null) ...[
              const SizedBox(height: 12),
              Text(jam.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            if (!JamController.supported)
              Text(l10n.jamUnsupported)
            else if (jam.isActive)
              _active(context, jam, l10n)
            else
              _idle(context, jam, l10n),
          ],
        ),
      ),
    );
  }

  Widget _idle(BuildContext context, JamController jam, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _busy ? null : () => _run(jam.startHosting),
          icon: const Icon(Icons.wifi_tethering_rounded),
          label: Text(l10n.jamStart),
        ),
        const SizedBox(height: 28),
        Text(l10n.jamNearby, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (jam.discovered.isEmpty)
          Text(
            jam.browsing ? l10n.jamSearching : l10n.jamNoneNearby,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant),
          )
        else
          for (final found in jam.discovered)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.speaker_group_outlined),
              title: Text(found.name),
              subtitle: Text('${found.host}:${found.port}'),
              onTap: _busy ? null : () => _joinPrompt(found),
            ),
        const SizedBox(height: 24),
        Text(l10n.jamManual, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _host,
          decoration: InputDecoration(labelText: l10n.jamHostHint),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _pin,
          decoration: InputDecoration(labelText: l10n.jamPin),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _busy ? null : _joinManual,
          child: Text(l10n.jamJoin),
        ),
      ],
    );
  }

  Widget _active(BuildContext context, JamController jam, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          jam.isPlayer ? l10n.jamYouArePlayer : l10n.jamYouAreGuest,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (jam.isPlayer) ...[
          Text('${l10n.jamPin}: ${jam.pin}', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            jam.localIp == null ? l10n.jamNoIp : '${jam.localIp}:${jam.port}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant),
          ),
          if (jam.joinUri != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: jam.joinUri!,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jam.joinUri!));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.jamCopied)));
              },
              icon: const Icon(Icons.copy_rounded),
              label: Text(l10n.jamCopyLink),
            ),
          ],
          if (isAndroid) ...[
            const SizedBox(height: 8),
            if (!jam.hotspotActive)
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _run(jam.startHotspot),
                icon: const Icon(Icons.wifi_rounded),
                label: Text(l10n.jamHotspot),
              )
            else ...[
              Text(l10n.jamHotspotActive(jam.hotspotSsid ?? '', jam.hotspotPassword ?? '')),
              TextButton(onPressed: jam.stopHotspot, child: Text(l10n.jamHotspotStop)),
            ],
          ],
        ],
        const SizedBox(height: 20),
        Text(l10n.jamMembers, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final member in jam.members)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(member.isPlayer ? Icons.speaker_rounded : Icons.smartphone_rounded),
            title: Text(member.name),
            subtitle: Text(member.isPlayer ? l10n.jamRolePlayer : l10n.jamRoleGuest),
          ),
        if (jam.remoteLibraries.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l10n.jamLibraryChip, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.jamLibraryBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: SwColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final lib in jam.remoteLibraries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.library_music_outlined),
              title: Text(l10n.jamLibraryFrom(lib.memberName)),
              subtitle: Text(l10n.tracksCount(lib.tracks.length)),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CollectionScreen.remote(
                      title: l10n.jamLibraryFrom(lib.memberName),
                      tracks: lib.tracks,
                    ),
                  ),
                );
              },
            ),
        ],
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: jam.stop,
          child: Text(l10n.jamLeave),
        ),
      ],
    );
  }

  Future<void> _joinPrompt(DiscoveredJam found) async {
    final l10n = AppLocalizations.of(context);
    final pin = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.jamJoinName(found.name)),
        content: TextField(
          controller: pin,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.jamPin),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.jamJoin)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(() => context.read<JamController>().joinDiscovered(found, pin.text));
  }

  Future<void> _joinManual() async {
    final parsed = JamJoinInfo.tryParse(_host.text);
    final host = parsed?.host ?? _host.text.trim();
    final port = parsed?.port ?? 0;
    final pin = _pin.text.trim().isNotEmpty ? _pin.text.trim() : (parsed?.pin ?? '');
    if (host.isEmpty || port <= 0) return;
    await _run(() => context.read<JamController>().joinManual(host: host, port: port, pin: pin));
  }
}
