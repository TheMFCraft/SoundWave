import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../data/catalog.dart';
import '../data/local_fs.dart';
import '../data/lyrics.dart';
import '../data/media_store.dart';
import '../data/models.dart';
import '../data/persist.dart';
import '../data/scanner.dart';

const _uuid = Uuid();

class LibraryController extends ChangeNotifier {
  LibraryController();

  bool ready = false;
  bool scanning = false;
  List<Track> tracks = [];
  List<Playlist> playlists = [];
  AppSettings settings = const AppSettings();

  final Map<String, Track> _byId = {};
  final Set<String> _lyricsTried = {};
  final Set<String> _lyricsBusy = {};
  final Set<String> _artTried = {};
  final Set<String> _artBusy = {};
  final List<String> _lyricsQueue = [];
  bool _lyricsPumping = false;
  int _lyricsUnsaved = 0;

  Track? trackById(String id) => _byId[id];

  List<Track> get likedTracks => tracks.where((t) => t.liked).toList();

  List<Track> recents({int limit = 12}) {
    final played = tracks.where((t) => t.lastPlayedAt != null).toList()
      ..sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return played.take(limit).toList();
  }

  List<AlbumGroup> get albums {
    final map = <String, List<Track>>{};
    for (final track in tracks) {
      map.putIfAbsent(track.albumKey, () => []).add(track);
    }
    final groups = [
      for (final entry in map.entries)
        AlbumGroup(
          key: entry.key,
          title: entry.value.first.album.isEmpty ? 'Unknown album' : entry.value.first.album,
          artist: entry.value.first.artist,
          tracks: entry.value,
        ),
    ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return groups;
  }

  List<ArtistGroup> get artists {
    final map = <String, List<Track>>{};
    for (final track in tracks) {
      final name = track.artist.isEmpty ? 'Unknown artist' : track.artist;
      map.putIfAbsent(name, () => []).add(track);
    }
    final groups = [
      for (final entry in map.entries) ArtistGroup(name: entry.key, tracks: entry.value),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return groups;
  }

  List<Track> moodTracks(Mood mood) {
    if (tracks.isEmpty) return const [];
    if (mood == Mood.forYou) {
      final ranked = [...tracks]..sort((a, b) {
          final like = (b.liked ? 1 : 0).compareTo(a.liked ? 1 : 0);
          if (like != 0) return like;
          final plays = b.playCount.compareTo(a.playCount);
          if (plays != 0) return plays;
          return b.addedAt.compareTo(a.addedAt);
        });
      return ranked.take(24).toList();
    }
    final matched = tracks.where((t) => trackMatchesMood(t, mood)).toList();
    if (matched.isNotEmpty) return matched;
    return [...tracks]..shuffle();
  }

  List<ArtistGroup> topMixes({int limit = 8}) {
    final ranked = [...artists]..sort((a, b) {
        final plays = b.tracks.fold<int>(0, (s, t) => s + t.playCount) -
            a.tracks.fold<int>(0, (s, t) => s + t.playCount);
        if (plays != 0) return plays;
        return b.tracks.length.compareTo(a.tracks.length);
      });
    return ranked.take(limit).toList();
  }

  Track? get featured {
    if (tracks.isEmpty) return null;
    final liked = likedTracks;
    if (liked.isNotEmpty) {
      liked.sort((a, b) => b.playCount.compareTo(a.playCount));
      return liked.first;
    }
    final recent = recents(limit: 1);
    if (recent.isNotEmpty) return recent.first;
    final copy = [...tracks]..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return copy.first;
  }

  Future<void> load() async {
    try {
      final raw = await readStore();
      if (raw != null && raw.isNotEmpty) {
        final snapshot = LibrarySnapshot.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        tracks = snapshot.tracks;
        playlists = snapshot.playlists;
        settings = snapshot.settings;
      }
    } catch (_) {
      tracks = [];
      playlists = [];
      settings = const AppSettings();
    }
    _index();
    ready = true;
    notifyListeners();
  }

  Future<void> persist() async {
    final snapshot = LibrarySnapshot(
      tracks: tracks,
      playlists: playlists,
      settings: settings,
    );
    await writeStore(jsonEncode(snapshot.toJson()));
  }

  Future<int> importFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: audioExtensions.map((e) => e.replaceFirst('.', '')).toList(),
      allowMultiple: true,
    );
    if (result == null) return 0;
    final paths = [
      for (final file in result.files)
        if (file.path != null) file.path!,
    ];
    return _ingestPaths(paths);
  }

  Future<int> scanDefaultMusic() => scanDeviceLibrary(silent: false);

  Future<int> scanDeviceLibrary({bool silent = false}) async {
    final granted = await _ensureAudioPermission();
    if (!granted) return -1;
    if (!silent) {
      scanning = true;
      notifyListeners();
    }
    final existingUris = {for (final t in tracks) t.uri};
    final existingMedia = {
      for (final t in tracks)
        if (t.id.startsWith('media_')) t.id,
    };
    final now = DateTime.now();
    var added = 0;
    try {
      if (isAndroid) {
        final songs = await queryDeviceAudio();
        for (final song in songs) {
          final mediaId = 'media_${song.mediaId}';
          final playUri = (song.path != null && song.path!.isNotEmpty) ? song.path! : song.contentUri;
          if (existingMedia.contains(mediaId) || existingUris.contains(playUri) || existingUris.contains(song.contentUri)) {
            continue;
          }
          var track = Track(
            id: mediaId,
            title: song.title.isEmpty ? (song.path ?? 'Track') : song.title,
            artist: song.artist,
            album: song.album,
            uri: playUri,
            genre: song.genre,
            durationMs: song.durationMs,
            albumId: song.albumId <= 0 ? null : song.albumId,
            addedAt: now,
          );
          tracks = [...tracks, track];
          _byId[track.id] = track;
          existingUris.add(playUri);
          existingMedia.add(mediaId);
          added += 1;
          _queueLyricsFetch(track.id);
          if (added % 12 == 0) {
            notifyListeners();
            await Future<void>.delayed(Duration.zero);
          }
        }
      }

      final folders = <String>{
        ...settings.folders,
        ...defaultMusicFolders(),
      }.where((folder) => folder.isNotEmpty).toSet();
      settings = settings.copyWith(folders: folders.toList());
      for (final folder in folders) {
        for (final path in listAudioFiles(folder)) {
          if (existingUris.contains(path)) continue;
          added += await _ingestParsed(parseTrackFile(path, addedAt: now));
          existingUris.add(path);
          if (added % 12 == 0) {
            notifyListeners();
            await Future<void>.delayed(Duration.zero);
          }
        }
      }
      if (added > 0) await persist();
    } finally {
      scanning = false;
      notifyListeners();
    }
    return added;
  }

  Future<Track> _cacheAlbumArt(Track track) async {
    if (track.artworkPath != null || track.albumId == null) return track;
    final bytes = await loadAlbumArt(track.albumId!);
    if (bytes == null || bytes.isEmpty) return track;
    final dir = await artworkDirectoryPath();
    final saved = await writeArtworkBytes(dir, 'album_${track.albumId}', bytes);
    if (saved == null) return track;
    return track.copyWith(artworkPath: saved);
  }

  Future<void> ensureArtwork(String trackId) async {
    final track = _byId[trackId];
    if (track == null || track.artworkPath != null || track.albumId == null) return;
    if (_artTried.contains(trackId) || _artBusy.contains(trackId)) return;
    _artBusy.add(trackId);
    try {
      final updated = await _cacheAlbumArt(track);
      _artTried.add(trackId);
      if (updated.artworkPath == null) return;
      final index = tracks.indexWhere((item) => item.id == trackId);
      if (index < 0) return;
      tracks = [...tracks]..[index] = updated;
      _byId[trackId] = updated;
      notifyListeners();
      await persist();
    } finally {
      _artBusy.remove(trackId);
    }
  }

  Future<void> ensureLyrics(String trackId, {bool interactive = true}) async {
    _lyricsQueue.remove(trackId);
    final track = _byId[trackId];
    if (!_canLookupLyrics(track, requireArtist: !interactive)) return;
    if (_lyricsTried.contains(trackId) || _lyricsBusy.contains(trackId)) return;
    _lyricsBusy.add(trackId);
    if (interactive) notifyListeners();
    try {
      final lyrics = await fetchLyrics(track!);
      _lyricsTried.add(trackId);
      if (lyrics == null || lyrics.trim().isEmpty) return;
      final index = tracks.indexWhere((item) => item.id == trackId);
      if (index < 0) return;
      final updated = tracks[index].copyWith(lyrics: lyrics);
      tracks = [...tracks]..[index] = updated;
      _byId[trackId] = updated;
      if (interactive) {
        await persist();
      } else {
        _lyricsUnsaved += 1;
        if (_lyricsUnsaved >= 8) {
          _lyricsUnsaved = 0;
          await persist();
        }
      }
      notifyListeners();
    } finally {
      _lyricsBusy.remove(trackId);
      if (interactive) notifyListeners();
    }
  }

  bool isFetchingLyrics(String trackId) => _lyricsBusy.contains(trackId);

  bool _canLookupLyrics(Track? track, {required bool requireArtist}) {
    if (track == null || track.lyrics.trim().isNotEmpty) return false;
    if (track.title.trim().isEmpty) return false;
    if (requireArtist && track.artist.trim().isEmpty) return false;
    return true;
  }

  void _queueLyricsFetch(String trackId) {
    if (!_canLookupLyrics(_byId[trackId], requireArtist: true)) return;
    if (_lyricsTried.contains(trackId) || _lyricsBusy.contains(trackId)) return;
    if (_lyricsQueue.contains(trackId)) return;
    _lyricsQueue.add(trackId);
    unawaited(_pumpLyricsQueue());
  }

  Future<void> _pumpLyricsQueue() async {
    if (_lyricsPumping) return;
    _lyricsPumping = true;
    try {
      while (_lyricsQueue.isNotEmpty) {
        final id = _lyricsQueue.removeAt(0);
        await ensureLyrics(id, interactive: false);
        await Future<void>.delayed(const Duration(milliseconds: 450));
      }
      if (_lyricsUnsaved > 0) {
        _lyricsUnsaved = 0;
        await persist();
      }
    } finally {
      _lyricsPumping = false;
    }
  }

  Future<int> importFolder() async {
    final folder = await FilePicker.platform.getDirectoryPath();
    if (folder == null) return 0;
    final folders = {...settings.folders, folder}.toList();
    settings = settings.copyWith(folders: folders);
    return rescan(extraFolders: [folder]);
  }

  Future<int> rescan({List<String> extraFolders = const []}) async {
    scanning = true;
    notifyListeners();
    final folders = {...settings.folders, ...extraFolders};
    final existing = {for (final t in tracks) t.uri: t};
    final now = DateTime.now();
    var added = 0;
    try {
      for (final folder in folders) {
        for (final path in listAudioFiles(folder)) {
          if (existing.containsKey(path)) continue;
          added += await _ingestParsed(parseTrackFile(path, addedAt: now));
        }
      }
      await persist();
    } finally {
      scanning = false;
      notifyListeners();
    }
    return added;
  }

  Future<int> _ingestPaths(List<String> paths) async {
    scanning = true;
    notifyListeners();
    final existing = {for (final t in tracks) t.uri: t};
    final now = DateTime.now();
    var added = 0;
    try {
      for (final path in paths) {
        if (!isAudioPath(path) || existing.containsKey(path)) continue;
        added += await _ingestParsed(parseTrackFile(path, addedAt: now));
      }
      await persist();
    } finally {
      scanning = false;
      notifyListeners();
    }
    return added;
  }

  Future<int> _ingestParsed(ParsedAudio parsed) async {
    var track = parsed.track;
    if (parsed.artwork != null && parsed.artwork!.isNotEmpty) {
      final dir = await artworkDirectoryPath();
      final saved = await writeArtworkBytes(dir, track.id, parsed.artwork!);
      if (saved != null) {
        track = track.copyWith(artworkPath: saved);
      }
    }
    tracks = [...tracks, track];
    _byId[track.id] = track;
    _queueLyricsFetch(track.id);
    return 1;
  }

  Future<void> toggleLike(String trackId) async {
    final index = tracks.indexWhere((t) => t.id == trackId);
    if (index < 0) return;
    final updated = tracks[index].copyWith(liked: !tracks[index].liked);
    tracks = [...tracks]..[index] = updated;
    _byId[trackId] = updated;
    notifyListeners();
    await persist();
  }

  Future<void> recordPlay(String trackId) async {
    final index = tracks.indexWhere((t) => t.id == trackId);
    if (index < 0) return;
    final current = tracks[index];
    final updated = current.copyWith(
      playCount: current.playCount + 1,
      lastPlayedAt: DateTime.now(),
    );
    tracks = [...tracks]..[index] = updated;
    _byId[trackId] = updated;
    notifyListeners();
    await persist();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    notifyListeners();
    await persist();
  }

  Future<void> rememberPlayback({
    required List<String> queueIds,
    required int index,
    required int positionMs,
    required bool shuffle,
    required PlayRepeat repeat,
  }) async {
    settings = settings.copyWith(
      lastQueueIds: queueIds,
      lastQueueIndex: index,
      lastPositionMs: positionMs,
      shuffle: shuffle,
      repeat: repeat,
    );
    await persist();
  }

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [trimmed, ...settings.recentSearches.where((s) => s != trimmed)].take(12).toList();
    await updateSettings(settings.copyWith(recentSearches: next));
  }

  Future<void> clearSearches() async {
    await updateSettings(settings.copyWith(recentSearches: const []));
  }

  Future<void> removeFolder(String folder) async {
    await updateSettings(
      settings.copyWith(folders: settings.folders.where((f) => f != folder).toList()),
    );
  }

  Future<Playlist> createPlaylist({String name = 'Playlist'}) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    playlists = [...playlists, playlist];
    notifyListeners();
    await persist();
    return playlist;
  }

  Future<void> savePlaylist(Playlist playlist) async {
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index < 0) {
      playlists = [...playlists, playlist];
    } else {
      playlists = [...playlists]..[index] = playlist;
    }
    notifyListeners();
    await persist();
  }

  Future<void> deletePlaylist(String id) async {
    playlists = playlists.where((p) => p.id != id).toList();
    notifyListeners();
    await persist();
  }

  Future<void> addToPlaylist(String playlistId, String trackId) async {
    final index = playlists.indexWhere((p) => p.id == playlistId);
    if (index < 0) return;
    final current = playlists[index];
    if (current.trackIds.contains(trackId)) return;
    await savePlaylist(current.copyWith(trackIds: [...current.trackIds, trackId]));
  }

  List<Track> tracksForPlaylist(Playlist playlist) {
    return [
      for (final id in playlist.trackIds)
        if (_byId[id] != null) _byId[id]!,
    ];
  }

  List<Track> sortedTracks(TrackSort sort) {
    final copy = [...tracks];
    switch (sort) {
      case TrackSort.title:
        copy.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case TrackSort.artist:
        copy.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
      case TrackSort.recentlyAdded:
        copy.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case TrackSort.mostPlayed:
        copy.sort((a, b) => b.playCount.compareTo(a.playCount));
    }
    return copy;
  }

  void _index() {
    _byId
      ..clear()
      ..addEntries(tracks.map((t) => MapEntry(t.id, t)));
  }

  Future<bool> _ensureAudioPermission() async {
    if (kIsWeb || !isAndroid) return true;
    final audio = await Permission.audio.request();
    if (audio.isGranted) return true;
    final storage = await Permission.storage.request();
    return storage.isGranted;
  }
}
