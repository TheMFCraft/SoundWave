import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../state/library_controller.dart';
import '../state/player_controller.dart';
import 'jam_hooks.dart';
import 'jam_models.dart';

class JamController extends ChangeNotifier implements JamPlaybackGate {
  JamController({required this.player, required this.library}) {
    player.attachJam(this);
    deviceName = 'SoundWave';
    memberId = 'web';
  }

  final PlayerController player;
  final LibraryController library;

  static const supported = false;

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

  @override
  bool get isActive => false;
  @override
  bool get isGuest => false;
  @override
  bool get isPlayer => false;
  String? get joinUri => null;
  @override
  Stream<Duration>? get remotePositionStream => null;
  @override
  Duration? get remotePosition => null;

  Future<void> startBrowsing() async {}
  Future<void> stopBrowsing() async {}
  Future<void> startHosting() async {}
  Future<void> joinDiscovered(DiscoveredJam jam, String enteredPin) async {}
  Future<void> joinManual({
    required String host,
    required int port,
    required String pin,
  }) async {}
  Future<void> startHotspot() async {}
  Future<void> stopHotspot() async {}
  Future<void> stop() async {}

  @override
  Future<void> commandPlayPause() async {}
  @override
  Future<void> commandNext() async {}
  @override
  Future<void> commandPrevious() async {}
  @override
  Future<void> commandSeek(Duration position) async {}
  @override
  Future<void> commandSkipTo(int index) async {}
  @override
  Future<void> commandPlayTracks(
    List<Track> tracks, {
    int startIndex = 0,
    QueueContext? context,
    bool shuffled = false,
  }) async {}
  @override
  Future<void> commandAddNext(Track track) async {}
  @override
  Future<void> commandAddAll(List<Track> tracks) async {}
  @override
  Future<void> commandRemove(int index) async {}
  @override
  Future<void> commandMove(int from, int to) async {}
  @override
  Future<void> commandClear() async {}
  @override
  Future<void> commandShuffle() async {}
  @override
  Future<void> commandRepeat() async {}
  @override
  Future<void> commandSpeed(double value) async {}
}
