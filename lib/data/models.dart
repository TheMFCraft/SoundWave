enum AppLanguage { system, en, de }

enum PlayRepeat { off, all, one }

enum LibraryFilter { all, playlists, artists, albums, jam }

enum TrackSort { title, artist, recentlyAdded, mostPlayed }

enum Mood { forYou, focus, workout, relax, night }

class AppSettings {
  const AppSettings({
    this.language = AppLanguage.system,
    this.folders = const [],
    this.recentSearches = const [],
    this.lastQueueIds = const [],
    this.lastQueueIndex = 0,
    this.lastPositionMs = 0,
    this.shuffle = false,
    this.repeat = PlayRepeat.off,
  });

  final AppLanguage language;
  final List<String> folders;
  final List<String> recentSearches;
  final List<String> lastQueueIds;
  final int lastQueueIndex;
  final int lastPositionMs;
  final bool shuffle;
  final PlayRepeat repeat;

  AppSettings copyWith({
    AppLanguage? language,
    List<String>? folders,
    List<String>? recentSearches,
    List<String>? lastQueueIds,
    int? lastQueueIndex,
    int? lastPositionMs,
    bool? shuffle,
    PlayRepeat? repeat,
  }) {
    return AppSettings(
      language: language ?? this.language,
      folders: folders ?? this.folders,
      recentSearches: recentSearches ?? this.recentSearches,
      lastQueueIds: lastQueueIds ?? this.lastQueueIds,
      lastQueueIndex: lastQueueIndex ?? this.lastQueueIndex,
      lastPositionMs: lastPositionMs ?? this.lastPositionMs,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language.name,
        'folders': folders,
        'recentSearches': recentSearches,
        'lastQueueIds': lastQueueIds,
        'lastQueueIndex': lastQueueIndex,
        'lastPositionMs': lastPositionMs,
        'shuffle': shuffle,
        'repeat': repeat.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppSettings();
    return AppSettings(
      language: AppLanguage.values.firstWhere(
        (value) => value.name == json['language'],
        orElse: () => AppLanguage.system,
      ),
      folders: (json['folders'] as List?)?.cast<String>() ?? const [],
      recentSearches: (json['recentSearches'] as List?)?.cast<String>() ?? const [],
      lastQueueIds: (json['lastQueueIds'] as List?)?.cast<String>() ?? const [],
      lastQueueIndex: json['lastQueueIndex'] as int? ?? 0,
      lastPositionMs: json['lastPositionMs'] as int? ?? 0,
      shuffle: json['shuffle'] as bool? ?? false,
      repeat: PlayRepeat.values.firstWhere(
        (value) => value.name == json['repeat'],
        orElse: () => PlayRepeat.off,
      ),
    );
  }
}

class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    this.genre = '',
    this.lyrics = '',
    this.durationMs = 0,
    this.year,
    this.artworkPath,
    this.albumId,
    required this.addedAt,
    this.playCount = 0,
    this.lastPlayedAt,
    this.liked = false,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String uri;
  final String genre;
  final String lyrics;
  final int durationMs;
  final int? year;
  final String? artworkPath;
  final int? albumId;
  final DateTime addedAt;
  final int playCount;
  final DateTime? lastPlayedAt;
  final bool liked;

  Duration get duration => Duration(milliseconds: durationMs);
  String get albumKey => '${artist.toLowerCase()}::${album.toLowerCase()}';
  String get searchBlob => '$title $artist $album $genre'.toLowerCase();

  Track copyWith({
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? lyrics,
    int? durationMs,
    int? year,
    String? artworkPath,
    int? albumId,
    DateTime? addedAt,
    int? playCount,
    DateTime? lastPlayedAt,
    bool? liked,
    bool clearArtwork = false,
  }) {
    return Track(
      id: id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      uri: uri,
      genre: genre ?? this.genre,
      lyrics: lyrics ?? this.lyrics,
      durationMs: durationMs ?? this.durationMs,
      year: year ?? this.year,
      artworkPath: clearArtwork ? null : (artworkPath ?? this.artworkPath),
      albumId: albumId ?? this.albumId,
      addedAt: addedAt ?? this.addedAt,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      liked: liked ?? this.liked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'uri': uri,
        'genre': genre,
        'lyrics': lyrics,
        'durationMs': durationMs,
        'year': year,
        'artworkPath': artworkPath,
        'albumId': albumId,
        'addedAt': addedAt.toIso8601String(),
        'playCount': playCount,
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
        'liked': liked,
      };

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      album: json['album'] as String? ?? '',
      uri: json['uri'] as String,
      genre: json['genre'] as String? ?? '',
      lyrics: json['lyrics'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      year: json['year'] as int?,
      artworkPath: json['artworkPath'] as String?,
      albumId: json['albumId'] as int?,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      playCount: json['playCount'] as int? ?? 0,
      lastPlayedAt: DateTime.tryParse(json['lastPlayedAt'] as String? ?? ''),
      liked: json['liked'] as bool? ?? false,
    );
  }
}

class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.trackIds = const [],
    this.coverPath,
    this.showOnHome = true,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final List<String> trackIds;
  final String? coverPath;
  final bool showOnHome;
  final DateTime createdAt;

  Playlist copyWith({
    String? name,
    String? description,
    List<String>? trackIds,
    String? coverPath,
    bool? showOnHome,
    bool clearCover = false,
  }) {
    return Playlist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      trackIds: trackIds ?? this.trackIds,
      coverPath: clearCover ? null : (coverPath ?? this.coverPath),
      showOnHome: showOnHome ?? this.showOnHome,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'trackIds': trackIds,
        'coverPath': coverPath,
        'showOnHome': showOnHome,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      trackIds: (json['trackIds'] as List?)?.cast<String>() ?? const [],
      coverPath: json['coverPath'] as String?,
      showOnHome: json['showOnHome'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class LibrarySnapshot {
  const LibrarySnapshot({
    required this.tracks,
    required this.playlists,
    required this.settings,
  });

  final List<Track> tracks;
  final List<Playlist> playlists;
  final AppSettings settings;

  Map<String, dynamic> toJson() => {
        'tracks': tracks.map((t) => t.toJson()).toList(),
        'playlists': playlists.map((p) => p.toJson()).toList(),
        'settings': settings.toJson(),
      };

  factory LibrarySnapshot.fromJson(Map<String, dynamic> json) {
    return LibrarySnapshot(
      tracks: (json['tracks'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      playlists: (json['playlists'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Playlist.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      settings: AppSettings.fromJson(json['settings'] as Map<String, dynamic>?),
    );
  }
}

class AlbumGroup {
  const AlbumGroup({
    required this.key,
    required this.title,
    required this.artist,
    required this.tracks,
  });

  final String key;
  final String title;
  final String artist;
  final List<Track> tracks;

  Track get representative => tracks.first;
}

class ArtistGroup {
  const ArtistGroup({required this.name, required this.tracks});

  final String name;
  final List<Track> tracks;
}

class QueueContext {
  const QueueContext({required this.kind, required this.name});

  final QueueKind kind;
  final String name;
}

enum QueueKind { playlist, album, queue, songs, likes, mix }
