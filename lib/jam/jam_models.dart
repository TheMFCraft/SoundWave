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

Map<String, dynamic> jamTrackToDto(Track track) => {
      'id': track.id,
      'title': track.title,
      'artist': track.artist,
      'album': track.album,
      'durationMs': track.durationMs,
      'genre': track.genre,
      'uri': track.uri,
    };

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
