import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'models.dart';

const audioExtensions = {
  '.mp3',
  '.m4a',
  '.aac',
  '.flac',
  '.wav',
  '.ogg',
  '.opus',
  '.wma',
  '.aiff',
  '.aif',
  '.alac',
};

const _uuid = Uuid();

class ParsedAudio {
  const ParsedAudio({required this.track, this.artwork});

  final Track track;
  final Uint8List? artwork;
}

bool isAudioPath(String path) {
  final ext = p.extension(path).toLowerCase();
  return audioExtensions.contains(ext);
}

List<String> listAudioFiles(String folder) {
  final dir = Directory(folder);
  if (!dir.existsSync()) return const [];
  final out = <String>[];
  try {
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (name.startsWith('.') || name.startsWith('._')) continue;
      if (isAudioPath(entity.path)) out.add(entity.path);
    }
  } on FileSystemException {
    return const [];
  }
  out.sort();
  return out;
}

ParsedAudio parseTrackFile(String path, {required DateTime addedAt, String? id}) {
  var title = p.basenameWithoutExtension(path);
  var artist = '';
  var album = '';
  var genre = '';
  var lyrics = '';
  var durationMs = 0;
  int? year;
  Uint8List? picture;

  try {
    final meta = readMetadata(File(path), getImage: true);
    title = _firstNonEmpty(_string(meta.title), title);
    artist = _firstNonEmpty(_string(meta.artist), _joinNames(meta));
    album = _firstNonEmpty(_string(meta.album), '');
    lyrics = _string(meta.lyrics);
    durationMs = meta.duration?.inMilliseconds ?? 0;
    year = _yearOf(meta.year);
    genre = _genresOf(meta);
    picture = _pictureOf(meta);
  } catch (_) {}

  return ParsedAudio(
    track: Track(
      id: id ?? _uuid.v4(),
      title: title,
      artist: artist,
      album: album,
      uri: path,
      genre: genre,
      lyrics: lyrics,
      durationMs: durationMs,
      year: year,
      addedAt: addedAt,
    ),
    artwork: picture,
  );
}

String _firstNonEmpty(String value, String fallback) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

String _string(Object? value) => value?.toString().trim() ?? '';

String _joinNames(dynamic meta) {
  try {
    final performers = meta.performers;
    if (performers is Iterable) {
      return performers.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join(', ');
    }
  } catch (_) {}
  return '';
}

int? _yearOf(Object? value) {
  if (value is int) return value;
  if (value is DateTime) return value.year;
  return int.tryParse(value?.toString() ?? '');
}

String _genresOf(dynamic meta) {
  try {
    final genres = meta.genres;
    if (genres is Iterable) {
      return genres.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).join(', ');
    }
  } catch (_) {}
  return '';
}

Uint8List? _pictureOf(dynamic meta) {
  try {
    final pictures = meta.pictures;
    if (pictures is Iterable && pictures.isNotEmpty) {
      final first = pictures.first;
      final bytes = first.bytes;
      if (bytes is Uint8List) return bytes;
    }
  } catch (_) {}
  return null;
}
