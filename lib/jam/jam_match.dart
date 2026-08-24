import '../data/models.dart';

String trackFingerprint(String title, String artist, int durationMs) {
  return '${title.trim().toLowerCase()}|${artist.trim().toLowerCase()}|${(durationMs / 1000).round()}';
}

Track? findLocalMatch(
  Iterable<Track> tracks, {
  required String title,
  required String artist,
  required int durationMs,
}) {
  final wanted = trackFingerprint(title, artist, durationMs);
  for (final track in tracks) {
    if (trackFingerprint(track.title, track.artist, track.durationMs) == wanted) {
      return track;
    }
  }
  return null;
}

bool jamNeedsTransfer({
  required Iterable<Track> library,
  required String title,
  required String artist,
  required int durationMs,
}) {
  return findLocalMatch(
        library,
        title: title,
        artist: artist,
        durationMs: durationMs,
      ) ==
      null;
}
