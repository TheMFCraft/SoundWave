import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../data/local_fs.dart';
import '../data/models.dart';
import '../state/library_controller.dart';
import '../state/player_controller.dart';
import 'jam_client.dart';
import 'jam_discovery.dart';
import 'jam_hooks.dart';
import 'jam_hotspot.dart';
import 'jam_match.dart';
import 'jam_models.dart';
import 'jam_net.dart';
import 'jam_protocol.dart';
import 'jam_server.dart';

class JamController extends ChangeNotifier implements JamPlaybackGate {
  JamController({required this.player, required this.library}) {
    player.attachJam(this);
    player.addListener(_onPlayerChanged);
    deviceName = deviceDisplayName();
    memberId = const Uuid().v4();
  }

  final PlayerController player;
  final LibraryController library;

  static const supported = true;

  JamRole role = JamRole.none;
  String deviceName = 'SoundWave';
  String memberId = '';
  String sessionId = '';
  String pin = '';
  String? localIp;
  int port = 0;
  String? error;
  String? hotspotSsid;
  String? hotspotPassword;
  bool hotspotActive = false;
  bool browsing = false;

  List<JamMember> members = const [];
  List<JamQueueItem> items = const [];
  List<DiscoveredJam> discovered = const [];

  final _discovery = JamDiscovery();
  final _server = JamServer();
  final _client = JamClient();
  final _position = StreamController<Duration>.broadcast();

  Timer? _syncTimer;
  Timer? _positionTimer;
  Directory? _cacheDir;
  int _basePositionMs = 0;
  DateTime _baseAt = DateTime.now();
  bool _remotePlaying = false;
  bool _ending = false;

  @override
  bool get isActive => role != JamRole.none;
  @override
  bool get isGuest => role == JamRole.guest;
  @override
  bool get isPlayer => role == JamRole.player;

  JamMember get self => JamMember(
        id: memberId,
        name: deviceName,
        isPlayer: isPlayer,
      );

  String? get joinUri {
    if (!isPlayer || localIp == null || port == 0) return null;
    return JamJoinInfo(host: localIp!, port: port, pin: pin).uri;
  }

  @override
  Stream<Duration>? get remotePositionStream => isGuest ? _position.stream : null;

  @override
  Duration? get remotePosition {
    if (!isGuest) return null;
    if (!_remotePlaying) return Duration(milliseconds: _basePositionMs);
    return Duration(
      milliseconds: _basePositionMs + DateTime.now().difference(_baseAt).inMilliseconds,
    );
  }

  Future<void> startBrowsing() async {
    if (kIsWeb) return;
    browsing = true;
    notifyListeners();
    _discovery.onChanged = () {
      discovered = _discovery.found.values.toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    };
    try {
      await _discovery.browse();
    } catch (e) {
      error = e.toString();
      browsing = false;
      notifyListeners();
    }
  }

  Future<void> stopBrowsing() async {
    browsing = false;
    await _discovery.stopBrowse();
    notifyListeners();
  }

  Future<void> startHosting() async {
    await _prepareLocalNetwork();
    await stop();
    sessionId = const Uuid().v4();
    pin = generatePin();
    localIp = await localIPv4();
    members = [self];
    items = const [];
    role = JamRole.player;
    _server.onMessage = _onServerMessage;
    _server.onDisconnect = (_, memberId) => _onMemberGone(memberId);
    port = await _server.start();
    await _discovery.publish(
      name: 'SoundWave $deviceName',
      port: port,
      sessionId: sessionId,
      playerName: deviceName,
    );
    await player.pauseLocalAudio();
    _startPositionPush();
    notifyListeners();
    _broadcastState(immediate: true);
  }

  Future<void> joinDiscovered(DiscoveredJam jam, String enteredPin) {
    return joinManual(host: jam.host, port: jam.port, pin: enteredPin);
  }

  Future<void> joinManual({
    required String host,
    required int port,
    required String pin,
  }) async {
    await _prepareLocalNetwork();
    await stop();
    this.pin = pin.trim();
    localIp = await localIPv4();
    await _client.startFileServer();
    _client.onMessage = _onClientMessage;
    _client.onClosed = () {
      if (!_ending && isGuest) {
        error = 'Jam getrennt';
        unawaited(stop());
      }
    };
    await _client.connect(host, port);
    _client.send(
      JamMessage('join', {
        'pin': this.pin,
        'member': self.toJson(),
        'filePort': _client.filePort,
        'host': localIp,
      }),
    );
    role = JamRole.guest;
    await player.pauseLocalAudio();
    _startGuestTicker();
    notifyListeners();
  }

  Future<void> startHotspot() async {
    if (!isAndroid || !isPlayer) return;
    await _prepareLocalNetwork(hotspot: true);
    final result = await JamHotspot.start();
    if (result == null) {
      error = 'Hotspot konnte nicht gestartet werden';
      notifyListeners();
      return;
    }
    hotspotActive = true;
    hotspotSsid = result.ssid;
    hotspotPassword = result.password;
    localIp = await localIPv4();
    notifyListeners();
  }

  Future<void> stopHotspot() async {
    await JamHotspot.stop();
    hotspotActive = false;
    hotspotSsid = null;
    hotspotPassword = null;
    notifyListeners();
  }

  Future<void> stop() async {
    _ending = true;
    _syncTimer?.cancel();
    _positionTimer?.cancel();
    await _discovery.stopPublish();
    await _server.close();
    await _client.close();
    if (hotspotActive) await JamHotspot.stop();
    if (isGuest) {
      player.applyGuestSnapshot(
        tracks: const [],
        index: 0,
        playing: false,
        duration: Duration.zero,
        shuffle: player.shuffle,
        repeat: player.repeat,
        speed: player.speed,
      );
    }
    await _clearUnusedCache();
    role = JamRole.none;
    sessionId = '';
    pin = '';
    port = 0;
    members = const [];
    items = const [];
    hotspotActive = false;
    hotspotSsid = null;
    hotspotPassword = null;
    error = null;
    _ending = false;
    notifyListeners();
  }

  @override
  Future<void> commandPlayPause() async {
    if (isGuest) {
      _client.send(const JamMessage('play_pause'));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(player.playPause);
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandNext() async {
    if (isGuest) {
      _client.send(const JamMessage('next'));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(player.next);
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandPrevious() async {
    if (isGuest) {
      _client.send(const JamMessage('previous'));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(player.previous);
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandSeek(Duration position) async {
    if (isGuest) {
      _client.send(JamMessage('seek', {'positionMs': position.inMilliseconds}));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(() => player.seek(position));
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandSkipTo(int index) async {
    if (isGuest) {
      _client.send(JamMessage('skip_to', {'index': index}));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(() => player.skipTo(index));
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandPlayTracks(
    List<Track> tracks, {
    int startIndex = 0,
    QueueContext? context,
    bool shuffled = false,
  }) async {
    if (tracks.isEmpty) return;
    if (isGuest) {
      await _offerAndSend('play_tracks', tracks, startIndex: startIndex, shuffled: shuffled);
      return;
    }
    if (!isPlayer) return;
    items = [
      for (var i = 0; i < tracks.length; i++)
        _itemFromLocal(tracks[i], indexHint: i),
    ];
    await _applyPlayerQueue(play: true, index: startIndex.clamp(0, items.length - 1));
  }

  @override
  Future<void> commandAddNext(Track track) async {
    if (isGuest) {
      await _offerAndSend('add_next', [track]);
      return;
    }
    if (!isPlayer) return;
    final item = _itemFromLocal(track);
    final insertAt = items.isEmpty ? 0 : (player.index + 1).clamp(0, items.length);
    items = [...items]..insert(insertAt, item);
    await _applyPlayerQueue(play: player.playing || items.length == 1, index: player.index);
  }

  @override
  Future<void> commandAddAll(List<Track> tracks) async {
    if (tracks.isEmpty) return;
    if (isGuest) {
      await _offerAndSend('add', tracks);
      return;
    }
    if (!isPlayer) return;
    if (items.isEmpty) {
      await commandPlayTracks(tracks);
      return;
    }
    items = [...items, for (final track in tracks) _itemFromLocal(track)];
    await _applyPlayerQueue(play: player.playing, index: player.index);
  }

  @override
  Future<void> commandRemove(int index) async {
    if (isGuest) {
      _client.send(JamMessage('remove', {'index': index}));
      return;
    }
    if (!isPlayer || index < 0 || index >= items.length) return;
    items = [...items]..removeAt(index);
    final nextIndex = index < player.index
        ? player.index - 1
        : player.index.clamp(0, items.isEmpty ? 0 : items.length - 1);
    await _applyPlayerQueue(play: player.playing && items.isNotEmpty, index: nextIndex);
  }

  @override
  Future<void> commandMove(int from, int to) async {
    if (isGuest) {
      _client.send(JamMessage('move', {'from': from, 'to': to}));
      return;
    }
    if (!isPlayer || from == to || from < 0 || to < 0 || from >= items.length) return;
    final next = [...items];
    final item = next.removeAt(from);
    next.insert(to.clamp(0, next.length), item);
    items = next;
    var index = player.index;
    if (from == index) {
      index = to;
    } else if (from < index && to >= index) {
      index -= 1;
    } else if (from > index && to <= index) {
      index += 1;
    }
    await _applyPlayerQueue(play: player.playing, index: index);
  }

  @override
  Future<void> commandClear() async {
    if (isGuest) {
      _client.send(const JamMessage('clear'));
      return;
    }
    if (!isPlayer) return;
    items = const [];
    await _applyPlayerQueue(play: false, index: 0);
  }

  @override
  Future<void> commandShuffle() async {
    if (isGuest) {
      _client.send(const JamMessage('shuffle'));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(player.toggleShuffle);
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandRepeat() async {
    if (isGuest) {
      _client.send(const JamMessage('repeat'));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(player.cycleRepeat);
    _broadcastState(immediate: true);
  }

  @override
  Future<void> commandSpeed(double value) async {
    if (isGuest) {
      _client.send(JamMessage('speed', {'value': value}));
      return;
    }
    if (!isPlayer) return;
    await player.runLocal(() => player.setSpeed(value));
    _broadcastState(immediate: true);
  }

  Future<void> _onServerMessage(String socketId, JamMessage message) async {
    switch (message.type) {
      case 'join':
        await _handleJoin(socketId, message);
      case 'play_pause':
        await commandPlayPause();
      case 'next':
        await commandNext();
      case 'previous':
        await commandPrevious();
      case 'seek':
        await commandSeek(Duration(milliseconds: message.data['positionMs'] as int? ?? 0));
      case 'skip_to':
        await commandSkipTo(message.data['index'] as int? ?? 0);
      case 'shuffle':
        await commandShuffle();
      case 'repeat':
        await commandRepeat();
      case 'speed':
        await commandSpeed((message.data['value'] as num?)?.toDouble() ?? 1);
      case 'remove':
        await commandRemove(message.data['index'] as int? ?? -1);
      case 'move':
        await commandMove(message.data['from'] as int? ?? 0, message.data['to'] as int? ?? 0);
      case 'clear':
        await commandClear();
      case 'play_tracks':
        await _ingestRemoteTracks(message, replace: true);
      case 'add':
        await _ingestRemoteTracks(message, replace: false);
      case 'add_next':
        await _ingestRemoteTracks(message, replace: false, next: true);
    }
  }

  void _onClientMessage(JamMessage message) {
    switch (message.type) {
      case 'join_ok':
        sessionId = message.data['sessionId'] as String? ?? sessionId;
        _applyState(message.data['state'] as Map? ?? const {});
      case 'join_denied':
        error = message.data['reason'] as String? ?? 'Beitritt abgelehnt';
        unawaited(stop());
      case 'state':
        _applyState(message.data);
      case 'error':
        error = message.data['reason'] as String? ?? 'Jam-Fehler';
        notifyListeners();
    }
  }

  Future<void> _handleJoin(String socketId, JamMessage message) async {
    final given = (message.data['pin'] as String? ?? '').trim();
    if (given != pin) {
      _server.sendToSocket(
        socketId,
        const JamMessage('join_denied', {'reason': 'Falscher PIN'}),
      );
      return;
    }
    final member = JamMember.fromJson(
      Map<String, dynamic>.from(message.data['member'] as Map? ?? const {}),
    );
    if (member.id.isEmpty) return;
    _server.bindMember(socketId, member.id);
    if (!members.any((item) => item.id == member.id)) {
      members = [...members, member];
    }
    notifyListeners();
    _server.sendToSocket(
      socketId,
      JamMessage('join_ok', {
        'sessionId': sessionId,
        'state': _statePayload(),
      }),
    );
    _broadcastState(immediate: true);
  }

  void _onMemberGone(String? id) {
    if (id == null) return;
    members = members.where((member) => member.id != id).toList();
    notifyListeners();
    _broadcastState(immediate: true);
  }

  Future<void> _ingestRemoteTracks(
    JamMessage message, {
    required bool replace,
    bool next = false,
  }) async {
    final raw = (message.data['tracks'] as List? ?? const []).whereType<Map>();
    final host = message.data['host'] as String?;
    final filePort = message.data['filePort'] as int?;
    final addedBy = JamMember.fromJson(
      Map<String, dynamic>.from(message.data['member'] as Map? ?? const {}),
    );
    final incoming = <JamQueueItem>[];
    for (final row in raw) {
      incoming.add(
        await _itemFromRemote(
          Map<String, dynamic>.from(row),
          addedBy: addedBy,
          host: host,
          filePort: filePort,
        ),
      );
    }
    if (incoming.isEmpty) return;
    if (replace || items.isEmpty) {
      items = incoming;
      await _applyPlayerQueue(
        play: true,
        index: (message.data['startIndex'] as int? ?? 0).clamp(0, items.length - 1),
      );
    } else if (next) {
      final insertAt = (player.index + 1).clamp(0, items.length);
      items = [...items]..insertAll(insertAt, incoming);
      await _applyPlayerQueue(play: player.playing, index: player.index);
    } else {
      items = [...items, ...incoming];
      await _applyPlayerQueue(play: player.playing, index: player.index);
    }
    unawaited(_transferPending());
  }

  JamQueueItem _itemFromLocal(Track track, {int indexHint = 0}) {
    return JamQueueItem(
      id: 'local_${track.id}_$indexHint${const Uuid().v4().substring(0, 8)}',
      track: track,
      addedById: memberId,
      addedByName: deviceName,
      transfer: JamTransferStatus.local,
    );
  }

  Future<JamQueueItem> _itemFromRemote(
    Map<String, dynamic> row, {
    required JamMember addedBy,
    String? host,
    int? filePort,
  }) async {
    final dto = Map<String, dynamic>.from(row['track'] as Map? ?? row);
    final token = row['token'] as String?;
    final match = findLocalMatch(
      library.tracks,
      title: dto['title'] as String? ?? '',
      artist: dto['artist'] as String? ?? '',
      durationMs: dto['durationMs'] as int? ?? 0,
    );
    if (match != null) {
      return JamQueueItem(
        id: const Uuid().v4(),
        track: match,
        addedById: addedBy.id,
        addedByName: addedBy.name,
        transfer: JamTransferStatus.local,
      );
    }
    return JamQueueItem(
      id: const Uuid().v4(),
      track: jamTrackFromDto(dto, uri: ''),
      addedById: addedBy.id,
      addedByName: addedBy.name,
      transfer: JamTransferStatus.pending,
      fileToken: token,
      sourceHost: host,
      sourcePort: filePort,
    );
  }

  Future<void> _offerAndSend(
    String type,
    List<Track> tracks, {
    int startIndex = 0,
    bool shuffled = false,
  }) async {
    final payload = <Map<String, dynamic>>[];
    for (final track in tracks) {
      final token = const Uuid().v4();
      if (localFileExists(track.uri)) {
        _client.offer(token, track.uri);
      }
      payload.add({
        'track': jamTrackToDto(track),
        'token': localFileExists(track.uri) ? token : null,
      });
    }
    _client.send(
      JamMessage(type, {
        'tracks': payload,
        'startIndex': startIndex,
        'shuffled': shuffled,
        'member': self.toJson(),
        'host': localIp,
        'filePort': _client.filePort,
      }),
    );
  }

  Future<void> _transferPending() async {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.transfer != JamTransferStatus.pending &&
          item.transfer != JamTransferStatus.failed) {
        continue;
      }
      final host = item.sourceHost;
      final port = item.sourcePort;
      final token = item.fileToken;
      if (host == null || port == null || token == null) {
        items = [...items]..[i] = item.copyWith(transfer: JamTransferStatus.failed);
        notifyListeners();
        continue;
      }
      items = [...items]..[i] = item.copyWith(transfer: JamTransferStatus.transferring, progress: 0);
      notifyListeners();
      _broadcastState();
      try {
        final dir = await _cache();
        final dest = p.join(dir.path, '${item.id}${p.extension(item.track.title)}.bin');
        await downloadJamFile(
          host: host,
          port: port,
          token: token,
          destPath: dest,
          onProgress: (received, total) {
            final progress = total <= 0 ? 0.0 : received / total;
            items = [
              for (var j = 0; j < items.length; j++)
                if (j == i) items[j].copyWith(progress: progress) else items[j],
            ];
            notifyListeners();
          },
        );
        final named = p.join(
          dir.path,
          '${item.id}${_guessExt(item.track.title, item.track.uri)}',
        );
        await File(dest).rename(named);
        items = [...items]
          ..[i] = item.copyWith(
            track: Track(
              id: item.track.id,
              title: item.track.title,
              artist: item.track.artist,
              album: item.track.album,
              uri: named,
              genre: item.track.genre,
              durationMs: item.track.durationMs,
              addedAt: item.track.addedAt,
            ),
            transfer: JamTransferStatus.ready,
            progress: 1,
          );
        await _applyPlayerQueue(play: player.playing || i == player.index, index: player.index);
      } catch (_) {
        items = [...items]..[i] = item.copyWith(transfer: JamTransferStatus.failed);
        notifyListeners();
        _broadcastState(immediate: true);
      }
    }
  }

  String _guessExt(String title, String uri) {
    final fromUri = p.extension(uri);
    if (fromUri.isNotEmpty && fromUri.length <= 5) return fromUri;
    return '.mp3';
  }

  Future<void> _applyPlayerQueue({required bool play, required int index}) async {
    await player.applyJamPlayerQueue(
      tracks: [for (final item in items) item.track],
      index: items.isEmpty ? 0 : index.clamp(0, items.length - 1),
      play: play,
    );
    notifyListeners();
    _broadcastState(immediate: true);
  }

  Map<String, dynamic> _statePayload() {
    return {
      'queue': [for (final item in items) item.toJson()],
      'index': player.index,
      'playing': player.playing,
      'positionMs': player.position.inMilliseconds,
      'durationMs': player.duration.inMilliseconds,
      'shuffle': player.shuffle,
      'repeat': player.repeat.name,
      'speed': player.speed,
      'members': [for (final member in members) member.toJson()],
      'playerName': deviceName,
      'serverTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  void _applyState(Map<dynamic, dynamic> raw) {
    final data = Map<String, dynamic>.from(raw);
    items = [
      for (final row in (data['queue'] as List? ?? const []).whereType<Map>())
        JamQueueItem.fromJson(Map<String, dynamic>.from(row)),
    ];
    members = [
      for (final row in (data['members'] as List? ?? const []).whereType<Map>())
        JamMember.fromJson(Map<String, dynamic>.from(row)),
    ];
    _basePositionMs = data['positionMs'] as int? ?? 0;
    _baseAt = DateTime.now();
    _remotePlaying = data['playing'] as bool? ?? false;
    player.applyGuestSnapshot(
      tracks: [for (final item in items) item.track],
      index: data['index'] as int? ?? 0,
      playing: _remotePlaying,
      duration: Duration(milliseconds: data['durationMs'] as int? ?? 0),
      shuffle: data['shuffle'] as bool? ?? false,
      repeat: PlayRepeat.values.firstWhere(
        (value) => value.name == data['repeat'],
        orElse: () => PlayRepeat.off,
      ),
      speed: (data['speed'] as num?)?.toDouble() ?? 1,
    );
    _position.add(Duration(milliseconds: _basePositionMs));
    notifyListeners();
  }

  void _broadcastState({bool immediate = false}) {
    if (!isPlayer) return;
    if (immediate) {
      _syncTimer?.cancel();
      _server.broadcast(JamMessage('state', _statePayload()));
      return;
    }
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 280), () {
      if (isPlayer) _server.broadcast(JamMessage('state', _statePayload()));
    });
  }

  void _onPlayerChanged() {
    if (isPlayer) _broadcastState();
  }

  void _startPositionPush() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isPlayer && player.playing) _broadcastState();
    });
  }

  void _startGuestTicker() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final value = remotePosition;
      if (value != null) _position.add(value);
    });
  }

  Future<Directory> _cache() async {
    if (_cacheDir != null) return _cacheDir!;
    final root = await getTemporaryDirectory();
    final dir = Directory(p.join(root.path, 'jam_cache'));
    await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  Future<void> _clearUnusedCache() async {
    final dir = _cacheDir;
    if (dir == null || !await dir.exists()) return;
    final keep = player.current?.uri;
    try {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path != keep) {
          await entity.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> _prepareLocalNetwork({bool hotspot = false}) async {
    if (!isAndroid) return;
    try {
      if (hotspot) {
        await Permission.locationWhenInUse.request();
      }
      await Permission.nearbyWifiDevices.request();
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(stop());
    player.removeListener(_onPlayerChanged);
    _position.close();
    super.dispose();
  }
}
