import '../data/models.dart';

abstract class JamPlaybackGate {
  bool get isActive;
  bool get isGuest;
  bool get isPlayer;

  Stream<Duration>? get remotePositionStream;
  Duration? get remotePosition;

  Future<void> commandPlayPause();
  Future<void> commandNext();
  Future<void> commandPrevious();
  Future<void> commandSeek(Duration position);
  Future<void> commandSkipTo(int index);
  Future<void> commandPlayTracks(
    List<Track> tracks, {
    int startIndex = 0,
    QueueContext? context,
    bool shuffled = false,
  });
  Future<void> commandAddNext(Track track);
  Future<void> commandAddAll(List<Track> tracks);
  Future<void> commandRemove(int index);
  Future<void> commandMove(int from, int to);
  Future<void> commandClear();
  Future<void> commandShuffle();
  Future<void> commandRepeat();
  Future<void> commandSpeed(double value);
}
