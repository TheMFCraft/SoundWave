import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/local_fs.dart';
import '../data/models.dart';
import '../data/player_widget.dart';
import '../jam/jam_hooks.dart';
import 'library_controller.dart';

class PlayerController extends ChangeNotifier {
  PlayerController(this.library);

  final LibraryController library;
  final AudioPlayer _player = AudioPlayer();
  JamPlaybackGate? jam;

  List<Track> queue = [];
  QueueContext context = const QueueContext(
    kind: QueueKind.queue,
    name: 'Queue',
  );
  int index = 0;
  bool playing = false;
  bool shuffle = false;
  PlayRepeat repeat = PlayRepeat.off;
  Duration duration = Duration.zero;
  double speed = 1;
  DateTime? sleepUntil;
  bool sleepEndOfTrack = false;
  bool ready = false;

  List<int> _sourceToQueue = const [];
  bool _bypassJam = false;

  Stream<Duration> get positionStream =>
      jam != null && jam!.isGuest && jam!.remotePositionStream != null
          ? jam!.remotePositionStream!
          : _player.positionStream;

  Duration get position {
    if (jam != null && jam!.isGuest && jam!.remotePosition != null) {
      return jam!.remotePosition!;
    }
    return _player.position;
  }

  AudioPlayer get raw => _player;
  Track? get current =>
      queue.isEmpty ? null : queue[index.clamp(0, queue.length - 1)];

  Timer? _sleepTimer;
  Timer? _persistTimer;
  Timer? _widgetTimer;
  StreamSubscription<PlayerState>? _playerSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<Duration?>? _durationSub;
  bool _handlingComplete = false;

  void attachJam(JamPlaybackGate gate) => jam = gate;

  Future<T> runLocal<T>(Future<T> Function() action) async {
    _bypassJam = true;
    try {
      return await action();
    } finally {
      _bypassJam = false;
    }
  }

  bool get _jamActive => !_bypassJam && jam != null && jam!.isActive;

  Future<void> init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}

    shuffle = library.settings.shuffle;
    repeat = library.settings.repeat;
    await _player.setShuffleModeEnabled(shuffle);
    await _player.setLoopMode(_loopMode);

    _playerSub = _player.playerStateStream.listen((state) {
      if (jam != null && jam!.isGuest) return;
      playing = state.playing;
      notifyListeners();
      if (state.processingState == ProcessingState.completed) {
        unawaited(_onComplete());
      }
    });
    _indexSub = _player.currentIndexStream.listen((value) {
      if (jam != null && jam!.isGuest) return;
      if (value == null) return;
      final mapped = _mapSourceIndex(value);
      if (mapped == index || mapped >= queue.length) return;
      index = mapped;
      notifyListeners();
      final track = current;
      if (track != null) {
        unawaited(library.recordPlay(track.id));
        unawaited(library.ensureLyrics(track.id));
      }
      _schedulePersist();
    });
    _durationSub = _player.durationStream.listen((value) {
      if (jam != null && jam!.isGuest) return;
      duration = value ?? current?.duration ?? Duration.zero;
      notifyListeners();
    });

    await _restore();
    ready = true;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _widgetTimer?.cancel();
    _widgetTimer = Timer(const Duration(milliseconds: 80), () {
      unawaited(syncPlayerWidget(track: current, playing: playing));
    });
  }

  Future<void> pauseLocalAudio() async {
    try {
      await _player.stop();
    } catch (_) {}
  }

  void applyGuestSnapshot({
    required List<Track> tracks,
    required int index,
    required bool playing,
    required Duration duration,
    required bool shuffle,
    required PlayRepeat repeat,
    required double speed,
  }) {
    queue = tracks;
    this.index = tracks.isEmpty ? 0 : index.clamp(0, tracks.length - 1);
    this.playing = playing;
    this.duration = duration;
    this.shuffle = shuffle;
    this.repeat = repeat;
    this.speed = speed;
    context = const QueueContext(kind: QueueKind.queue, name: 'Jam');
    notifyListeners();
  }

  Future<void> applyJamPlayerQueue({
    required List<Track> tracks,
    required int index,
    required bool play,
    Duration position = Duration.zero,
  }) async {
    queue = tracks;
    this.index = tracks.isEmpty ? 0 : index.clamp(0, tracks.length - 1);
    context = const QueueContext(kind: QueueKind.queue, name: 'Jam');
    await _loadJam(play: play, position: position);
  }

  Future<void> clearQueue() async {
    if (_jamActive) {
      await jam!.commandClear();
      return;
    }
    queue = [];
    index = 0;
    await _player.stop();
    notifyListeners();
    _schedulePersist();
  }

  Future<void> playTracks(
    List<Track> tracks, {
    int startIndex = 0,
    QueueContext? context,
    bool shuffled = false,
  }) async {
    if (_jamActive) {
      await jam!.commandPlayTracks(
        tracks,
        startIndex: startIndex,
        context: context,
        shuffled: shuffled,
      );
      return;
    }
    if (tracks.isEmpty) return;
    final playable = [
      for (final track in tracks)
        if (_exists(track)) track,
    ];
    if (playable.isEmpty) return;
    this.context = context ?? this.context;
    queue = playable;
    index = startIndex.clamp(0, playable.length - 1);
    if (shuffled) {
      shuffle = true;
      await _player.setShuffleModeEnabled(true);
    }
    await _load(play: true);
  }

  Future<void> playPause() async {
    if (_jamActive) {
      await jam!.commandPlayPause();
      return;
    }
    if (queue.isEmpty) {
      final fallback = library.moodTracks(Mood.forYou);
      if (fallback.isEmpty) return;
      await playTracks(
        fallback,
        context: const QueueContext(kind: QueueKind.mix, name: 'SoundWave'),
      );
      return;
    }
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    if (_jamActive) {
      await jam!.commandNext();
      return;
    }
    if (queue.isEmpty) return;
    try {
      await _player.seekToNext();
    } catch (_) {
      await _player.seek(Duration.zero, index: (index + 1) % queue.length);
      await _player.play();
    }
  }

  Future<void> previous() async {
    if (_jamActive) {
      await jam!.commandPrevious();
      return;
    }
    if (queue.isEmpty) return;
    final position = _player.position;
    if (position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    try {
      await _player.seekToPrevious();
    } catch (_) {
      await _player.seek(Duration.zero, index: index == 0 ? 0 : index - 1);
    }
  }

  Future<void> seek(Duration position) async {
    if (_jamActive) {
      await jam!.commandSeek(position);
      return;
    }
    await _player.seek(position);
  }

  Future<void> skipTo(int nextIndex) async {
    if (_jamActive) {
      await jam!.commandSkipTo(nextIndex);
      return;
    }
    if (nextIndex < 0 || nextIndex >= queue.length) return;
    await _player.seek(Duration.zero, index: nextIndex);
    await _player.play();
  }

  Future<void> toggleShuffle() async {
    if (_jamActive) {
      await jam!.commandShuffle();
      return;
    }
    shuffle = !shuffle;
    await _player.setShuffleModeEnabled(shuffle);
    if (shuffle) {
      try {
        await _player.shuffle();
      } catch (_) {}
    }
    notifyListeners();
    _schedulePersist();
  }

  Future<void> cycleRepeat() async {
    if (_jamActive) {
      await jam!.commandRepeat();
      return;
    }
    repeat = switch (repeat) {
      PlayRepeat.off => PlayRepeat.all,
      PlayRepeat.all => PlayRepeat.one,
      PlayRepeat.one => PlayRepeat.off,
    };
    await _player.setLoopMode(_loopMode);
    notifyListeners();
    _schedulePersist();
  }

  Future<void> setSpeed(double value) async {
    if (_jamActive) {
      await jam!.commandSpeed(value);
      return;
    }
    speed = value;
    await _player.setSpeed(value);
    notifyListeners();
  }

  Future<void> addNext(Track track) async {
    if (_jamActive) {
      await jam!.commandAddNext(track);
      return;
    }
    if (!_exists(track)) return;
    if (queue.isEmpty) {
      await playTracks([track]);
      return;
    }
    final insertAt = (index + 1).clamp(0, queue.length);
    queue = [...queue]..insert(insertAt, track);
    try {
      await _player.addAudioSource(_source(track));
    } catch (_) {
      await _load(play: playing);
      return;
    }
    notifyListeners();
  }

  Future<void> addToQueue(Track track) async {
    await addAllToQueue([track]);
  }

  Future<void> addAllToQueue(List<Track> tracks) async {
    if (_jamActive) {
      await jam!.commandAddAll(tracks);
      return;
    }
    final playable = [
      for (final track in tracks)
        if (_exists(track)) track,
    ];
    if (playable.isEmpty) return;
    if (queue.isEmpty) {
      await playTracks(playable);
      return;
    }
    queue = [...queue, ...playable];
    try {
      for (final track in playable) {
        await _player.addAudioSource(_source(track));
      }
    } catch (_) {
      await _load(play: playing);
      return;
    }
    notifyListeners();
  }

  Future<void> removeFromQueue(int removeIndex) async {
    if (_jamActive) {
      await jam!.commandRemove(removeIndex);
      return;
    }
    if (removeIndex < 0 || removeIndex >= queue.length) return;
    queue = [...queue]..removeAt(removeIndex);
    if (queue.isEmpty) {
      await _player.stop();
      index = 0;
      notifyListeners();
      return;
    }
    await _load(
      play: playing,
      restoreIndex: removeIndex < index ? index - 1 : index,
    );
  }

  Future<void> moveQueueItem(int from, int to) async {
    if (_jamActive) {
      await jam!.commandMove(from, to);
      return;
    }
    if (from == to) return;
    final items = [...queue];
    final item = items.removeAt(from);
    items.insert(to, item);
    queue = items;
    if (from == index) {
      index = to;
    } else if (from < index && to >= index) {
      index -= 1;
    } else if (from > index && to <= index) {
      index += 1;
    }
    await _load(play: playing, restoreIndex: index);
  }

  void setSleepTimer({Duration? duration, bool endOfTrack = false}) {
    _sleepTimer?.cancel();
    sleepEndOfTrack = endOfTrack;
    if (duration == null && !endOfTrack) {
      sleepUntil = null;
      notifyListeners();
      return;
    }
    if (endOfTrack) {
      sleepUntil = null;
      notifyListeners();
      return;
    }
    sleepUntil = DateTime.now().add(duration!);
    _sleepTimer = Timer(duration, () async {
      sleepUntil = null;
      sleepEndOfTrack = false;
      await pause();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> pause() async {
    if (_jamActive && jam!.isGuest) {
      if (playing) await jam!.commandPlayPause();
      return;
    }
    await _player.pause();
  }

  Future<void> _onComplete() async {
    if (_handlingComplete) return;
    _handlingComplete = true;
    try {
      if (sleepEndOfTrack) {
        sleepEndOfTrack = false;
        await _player.pause();
        notifyListeners();
        return;
      }
      if (repeat == PlayRepeat.one) {
        await _player.seek(Duration.zero);
        await _player.play();
        return;
      }
      if (index >= queue.length - 1 && repeat == PlayRepeat.off) {
        await _player.pause();
        await _player.seek(Duration.zero);
        return;
      }
      await next();
    } finally {
      _handlingComplete = false;
    }
  }

  Future<void> _load({
    required bool play,
    int? restoreIndex,
    Duration position = Duration.zero,
  }) async {
    _sourceToQueue = const [];
    index = (restoreIndex ?? index).clamp(
      0,
      queue.isEmpty ? 0 : queue.length - 1,
    );
    final sources = [for (final track in queue) _source(track)];
    if (sources.isEmpty) return;
    await _player.setAudioSources(
      sources,
      initialIndex: index,
      initialPosition: position,
    );
    await _player.setShuffleModeEnabled(shuffle);
    await _player.setLoopMode(_loopMode);
    if (play) await _player.play();
    final playingTrack = current;
    if (playingTrack != null) unawaited(library.ensureLyrics(playingTrack.id));
    _schedulePersist();
    notifyListeners();
  }

  Future<void> _loadJam({
    required bool play,
    Duration position = Duration.zero,
  }) async {
    final sources = <AudioSource>[];
    final map = <int>[];
    for (var i = 0; i < queue.length; i++) {
      if (!_exists(queue[i])) continue;
      map.add(i);
      sources.add(_source(queue[i]));
    }
    _sourceToQueue = map;
    if (sources.isEmpty) {
      await _player.stop();
      playing = false;
      notifyListeners();
      return;
    }
    var sourceIndex = map.indexOf(index);
    if (sourceIndex < 0) {
      await _player.pause();
      playing = false;
      notifyListeners();
      return;
    }
    await _player.setAudioSources(
      sources,
      initialIndex: sourceIndex,
      initialPosition: position,
    );
    await _player.setShuffleModeEnabled(shuffle);
    await _player.setLoopMode(_loopMode);
    if (play) await _player.play();
    notifyListeners();
  }

  int _mapSourceIndex(int sourceIndex) {
    if (_sourceToQueue.isEmpty) return sourceIndex;
    if (sourceIndex < 0 || sourceIndex >= _sourceToQueue.length) return index;
    return _sourceToQueue[sourceIndex];
  }

  AudioSource _source(Track track) {
    final uri = _uriFor(track);
    return AudioSource.uri(
      uri,
      tag: MediaItem(
        id: track.id,
        title: track.title,
        album: track.album.isEmpty ? null : track.album,
        artist: track.artist.isEmpty ? null : track.artist,
        duration: track.durationMs > 0 ? track.duration : null,
        artUri: track.artworkPath == null
            ? null
            : Uri.parse('file://${track.artworkPath}'),
        playable: true,
      ),
    );
  }

  Uri _uriFor(Track track) {
    if (track.uri.startsWith('content:') ||
        track.uri.startsWith('file:') ||
        track.uri.startsWith('http')) {
      return Uri.parse(track.uri);
    }
    return Uri.file(track.uri);
  }

  bool _exists(Track track) {
    if (kIsWeb || track.uri.startsWith('content:')) return true;
    return localFileExists(track.uri);
  }

  LoopMode get _loopMode => switch (repeat) {
        PlayRepeat.off => LoopMode.off,
        PlayRepeat.all => LoopMode.all,
        PlayRepeat.one => LoopMode.one,
      };

  Future<void> _restore() async {
    final ids = library.settings.lastQueueIds;
    if (ids.isEmpty) return;
    final restored = [
      for (final id in ids)
        if (library.trackById(id) != null && _exists(library.trackById(id)!))
          library.trackById(id)!,
    ];
    if (restored.isEmpty) return;
    queue = restored;
    index = library.settings.lastQueueIndex.clamp(0, restored.length - 1);
    context = const QueueContext(kind: QueueKind.queue, name: 'SoundWave');
    await _load(
      play: false,
      restoreIndex: index,
      position: Duration(milliseconds: library.settings.lastPositionMs),
    );
  }

  void _schedulePersist() {
    if (jam != null && jam!.isActive) return;
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(seconds: 2), () {
      unawaited(
        library.rememberPlayback(
          queueIds: [for (final t in queue) t.id],
          index: index,
          positionMs: _player.position.inMilliseconds,
          shuffle: shuffle,
          repeat: repeat,
        ),
      );
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _persistTimer?.cancel();
    _widgetTimer?.cancel();
    _playerSub?.cancel();
    _indexSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
