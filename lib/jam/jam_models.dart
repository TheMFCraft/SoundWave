import '../data/models.dart';

enum JamRole { none, player, guest }

enum JamTransferStatus { local, pending, transferring, ready, failed }

class JamMember {
  const JamMember({
    required this.id,
    required this.name,
    this.isPlayer = false,
  });

  final String id;
  final String name;
  final bool isPlayer;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isPlayer': isPlayer,
      };

  factory JamMember.fromJson(Map<String, dynamic> json) {
    return JamMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isPlayer: json['isPlayer'] as bool? ?? false,
    );
  }

  JamMember copyWith({String? name, bool? isPlayer}) {
    return JamMember(
      id: id,
      name: name ?? this.name,
      isPlayer: isPlayer ?? this.isPlayer,
    );
  }
}

class JamQueueItem {
  const JamQueueItem({
    required this.id,
    required this.track,
    required this.addedById,
    required this.addedByName,
    this.transfer = JamTransferStatus.local,
    this.progress = 0,
    this.fileToken,
    this.sourceHost,
    this.sourcePort,
  });

  final String id;
  final Track track;
  final String addedById;
  final String addedByName;
  final JamTransferStatus transfer;
  final double progress;
  final String? fileToken;
  final String? sourceHost;
  final int? sourcePort;

  bool get playable =>
      transfer == JamTransferStatus.local || transfer == JamTransferStatus.ready;

  JamQueueItem copyWith({
    Track? track,
    JamTransferStatus? transfer,
    double? progress,
    String? fileToken,
    String? sourceHost,
    int? sourcePort,
  }) {
    return JamQueueItem(
      id: id,
      track: track ?? this.track,
      addedById: addedById,
      addedByName: addedByName,
      transfer: transfer ?? this.transfer,
      progress: progress ?? this.progress,
      fileToken: fileToken ?? this.fileToken,
      sourceHost: sourceHost ?? this.sourceHost,
      sourcePort: sourcePort ?? this.sourcePort,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'track': jamTrackToDto(track),
        'addedById': addedById,
        'addedByName': addedByName,
        'transfer': transfer.name,
        'progress': progress,
      };

  factory JamQueueItem.fromJson(Map<String, dynamic> json) {
    final dto = Map<String, dynamic>.from(json['track'] as Map? ?? const {});
    return JamQueueItem(
      id: json['id'] as String? ?? '',
      track: jamTrackFromDto(dto, uri: dto['uri'] as String? ?? ''),
      addedById: json['addedById'] as String? ?? '',
      addedByName: json['addedByName'] as String? ?? '',
      transfer: JamTransferStatus.values.firstWhere(
        (value) => value.name == json['transfer'],
        orElse: () => JamTransferStatus.pending,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
    );
  }
}

class JamRemoteLibrary {
  const JamRemoteLibrary({
    required this.memberId,
    required this.memberName,
    required this.tracks,
  });

  final String memberId;
  final String memberName;
  final List<Track> tracks;

  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'tracks': [for (final track in tracks) jamCatalogToDto(track)],
      };

  factory JamRemoteLibrary.fromJson(Map<String, dynamic> json) {
    final memberId = json['memberId'] as String? ?? '';
    return JamRemoteLibrary(
      memberId: memberId,
      memberName: json['memberName'] as String? ?? '',
      tracks: [
        for (final row in (json['tracks'] as List? ?? const []).whereType<Map>())
          jamCatalogFromDto(Map<String, dynamic>.from(row), memberId: memberId),
      ],
    );
  }
}

class DiscoveredJam {
  const DiscoveredJam({
    required this.name,
    required this.host,
    required this.port,
    required this.sessionId,
  });

  final String name;
  final String host;
  final int port;
  final String sessionId;
}

class JamJoinInfo {
  const JamJoinInfo({
    required this.host,
    required this.port,
    required this.pin,
  });

  final String host;
  final int port;
  final String pin;

  String get uri => 'soundwave://jam?h=$host&p=$port&c=$pin';

  static JamJoinInfo? tryParse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final parsed = Uri.tryParse(text);
    if (parsed != null && parsed.queryParameters.containsKey('h')) {
      final host = parsed.queryParameters['h'] ?? '';
      final port = int.tryParse(parsed.queryParameters['p'] ?? '') ?? 0;
      final pin = parsed.queryParameters['c'] ?? '';
      if (host.isEmpty || port <= 0) return null;
      return JamJoinInfo(host: host, port: port, pin: pin);
    }
    final parts = text.split(RegExp(r'[:\s]+'));
    if (parts.length >= 2) {
      final port = int.tryParse(parts[1]);
      if (port == null) return null;
      return JamJoinInfo(
        host: parts[0],
        port: port,
        pin: parts.length >= 3 ? parts[2] : '',
      );
    }
    return null;
  }
}

const jamCatalogScheme = 'jamcat';

Map<String, dynamic> jamTrackToDto(Track track) {
  final catalog = parseJamCatalogUri(track.uri);
  return {
    'id': catalog?.$2 ?? track.id,
    'title': track.title,
    'artist': track.artist,
    'album': track.album,
    'durationMs': track.durationMs,
    'genre': track.genre,
    'ext': jamFileExtension(track.uri),
  };
}

Map<String, dynamic> jamCatalogToDto(Track track) {
  final catalog = parseJamCatalogUri(track.uri);
  return {
    'id': catalog?.$2 ?? track.id,
    'title': track.title,
    'artist': track.artist,
    'album': track.album,
    'durationMs': track.durationMs,
    'genre': track.genre,
  };
}

Track jamTrackFromDto(Map<String, dynamic> json, {required String uri}) {
  return Track(
    id: json['id'] as String? ?? 'jam_${json['title']}',
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    album: json['album'] as String? ?? '',
    uri: uri,
    genre: json['genre'] as String? ?? '',
    durationMs: json['durationMs'] as int? ?? 0,
    addedAt: DateTime.now(),
  );
}

Track jamCatalogFromDto(Map<String, dynamic> json, {required String memberId}) {
  final originalId = json['id'] as String? ?? '';
  return Track(
    id: 'jamcat_${memberId}_$originalId',
    title: json['title'] as String? ?? '',
    artist: json['artist'] as String? ?? '',
    album: json['album'] as String? ?? '',
    uri: jamCatalogUri(memberId, originalId),
    genre: json['genre'] as String? ?? '',
    durationMs: json['durationMs'] as int? ?? 0,
    addedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );
}

String jamCatalogUri(String memberId, String originalId) {
  return '$jamCatalogScheme://$memberId/${Uri.encodeComponent(originalId)}';
}

(String memberId, String originalId)? parseJamCatalogUri(String uri) {
  const prefix = '$jamCatalogScheme://';
  if (!uri.startsWith(prefix)) return null;
  final rest = uri.substring(prefix.length);
  final slash = rest.indexOf('/');
  if (slash <= 0) return null;
  final memberId = rest.substring(0, slash);
  final originalId = Uri.decodeComponent(rest.substring(slash + 1));
  if (memberId.isEmpty || originalId.isEmpty) return null;
  return (memberId, originalId);
}

bool isJamCatalogTrack(Track track) => track.uri.startsWith('$jamCatalogScheme://');

String jamFileExtension(String uri) {
  final match = RegExp(r'\.([a-zA-Z0-9]{2,5})$').firstMatch(uri.split('?').first);
  if (match == null) return '.mp3';
  return '.${match.group(1)!.toLowerCase()}';
}
