import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

Future<String?> fetchLyrics(Track track) async {
  final title = track.title.trim();
  if (title.isEmpty) return null;
  final artist = track.artist.trim();
  final duration = track.durationMs > 0 ? (track.durationMs / 1000).round() : null;

  final exact = await _get(
    artistName: artist,
    trackName: title,
    albumName: track.album.trim(),
    duration: duration,
  );
  if (exact != null && exact.isNotEmpty) return exact;

  return _search(artist: artist, title: title);
}

Future<String?> _get({
  required String artistName,
  required String trackName,
  required String albumName,
  required int? duration,
}) async {
  final params = {
    'artist_name': artistName,
    'track_name': trackName,
    if (albumName.isNotEmpty) 'album_name': albumName,
    if (duration != null) 'duration': '$duration',
  };
  final uri = Uri.https('lrclib.net', '/api/get', params);
  try {
    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    return _plain(jsonDecode(response.body));
  } catch (_) {
    return null;
  }
}

Future<String?> _search({required String artist, required String title}) async {
  final q = [artist, title].where((part) => part.isNotEmpty).join(' ');
  if (q.isEmpty) return null;
  final uri = Uri.https('lrclib.net', '/api/search', {'q': q});
  try {
    final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) return null;
    return _plain(decoded.first);
  } catch (_) {
    return null;
  }
}

String? _plain(Object? decoded) {
  if (decoded is! Map) return null;
  final plain = decoded['plainLyrics'] as String?;
  if (plain != null && plain.trim().isNotEmpty) return plain.trim();
  final synced = decoded['syncedLyrics'] as String?;
  if (synced == null || synced.trim().isEmpty) return null;
  return synced
      .replaceAll(RegExp(r'\[[^\]]+\]'), '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .join('\n');
}

const _headers = {
  'User-Agent': 'SoundWave/1.0 (de.cylone.soundwave)',
};
