import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('de.cylone.soundwave/media');

class DeviceSong {
  const DeviceSong({
    required this.mediaId,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.contentUri,
    required this.albumId,
    this.path,
    this.genre = '',
  });

  final int mediaId;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String contentUri;
  final int albumId;
  final String? path;
  final String genre;
}

Future<List<DeviceSong>> queryDeviceAudio() async {
  if (kIsWeb) return const [];
  try {
    final raw = await _channel.invokeMethod<List<dynamic>>('queryAudio');
    if (raw == null) return const [];
    return [
      for (final item in raw)
        if (item is Map)
          DeviceSong(
            mediaId: (item['id'] as num?)?.toInt() ?? 0,
            title: (item['title'] as String?)?.trim() ?? '',
            artist: _cleanArtist(item['artist'] as String?),
            album: (item['album'] as String?)?.trim() ?? '',
            durationMs: (item['durationMs'] as num?)?.toInt() ?? 0,
            contentUri: item['contentUri'] as String? ?? '',
            albumId: (item['albumId'] as num?)?.toInt() ?? 0,
            path: item['path'] as String?,
            genre: (item['genre'] as String?)?.trim() ?? '',
          ),
    ];
  } catch (_) {
    return const [];
  }
}

Future<Uint8List?> loadAlbumArt(int albumId) async {
  if (albumId <= 0) return null;
  try {
    final raw = await _channel.invokeMethod('loadAlbumArt', {'albumId': albumId});
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return null;
  } catch (_) {
    return null;
  }
}

String _cleanArtist(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == '<unknown>') return '';
  return trimmed;
}
