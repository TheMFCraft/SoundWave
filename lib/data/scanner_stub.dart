import 'dart:typed_data';

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

class ParsedAudio {
  const ParsedAudio({required this.track, this.artwork});

  final Track track;
  final Uint8List? artwork;
}

bool isAudioPath(String path) => false;

List<String> listAudioFiles(String folder) => const [];

ParsedAudio parseTrackFile(String path, {required DateTime addedAt, String? id}) {
  return ParsedAudio(
    track: Track(
      id: id ?? const Uuid().v4(),
      title: path,
      artist: '',
      album: '',
      uri: path,
      addedAt: addedAt,
    ),
  );
}
