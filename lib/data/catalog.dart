import 'models.dart';

bool trackMatchesMood(Track track, Mood mood) {
  if (mood == Mood.forYou) return true;
  final blob = '${track.genre} ${track.album} ${track.title}'.toLowerCase();
  final needles = switch (mood) {
    Mood.forYou => const <String>[],
    Mood.focus => const [
        'classic',
        'ambient',
        'lofi',
        'lo-fi',
        'lo fi',
        'instrumental',
        'piano',
        'study',
        'soundtrack',
        'score',
        'minimal',
      ],
    Mood.workout => const [
        'electronic',
        'edm',
        'dance',
        'hip hop',
        'hip-hop',
        'hiphop',
        'rock',
        'metal',
        'pop',
        'house',
        'techno',
        'drum',
        'bass',
        'workout',
      ],
    Mood.relax => const [
        'jazz',
        'ambient',
        'acoustic',
        'soul',
        'chill',
        'classical',
        'folk',
        'sleep',
        'calm',
      ],
    Mood.night => const [
        'synth',
        'electronic',
        'indie',
        'alternative',
        'retrowave',
        'outrun',
        'dark',
        'night',
        'drive',
        'vapor',
      ],
  };
  return needles.any(blob.contains);
}

bool trackMatchesGenre(Track track, String genreKey) {
  final blob = '${track.genre} ${track.album} ${track.title}'.toLowerCase();
  final needles = switch (genreKey) {
    'pop' => const ['pop'],
    'rock' => const ['rock', 'metal', 'punk', 'indie rock'],
    'hiphop' => const ['hip hop', 'hip-hop', 'hiphop', 'rap', 'r&b', 'rnb'],
    'electronic' => const [
        'electronic',
        'edm',
        'house',
        'techno',
        'synth',
        'dance',
        'electro',
      ],
    'classical' => const ['classic', 'orchestra', 'piano', 'opera', 'score'],
    'jazz' => const ['jazz', 'blues', 'swing', 'bossa'],
    _ => [genreKey.toLowerCase()],
  };
  return needles.any(blob.contains);
}

List<Track> searchTracks(List<Track> tracks, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return tracks;
  final tokens = q.split(RegExp(r'\s+'));
  final scored = <(Track, int)>[];
  for (final track in tracks) {
    var score = 0;
    for (final token in tokens) {
      if (track.title.toLowerCase().contains(token)) score += 8;
      if (track.artist.toLowerCase().contains(token)) score += 6;
      if (track.album.toLowerCase().contains(token)) score += 4;
      if (track.genre.toLowerCase().contains(token)) score += 3;
      if (score == 0 && track.searchBlob.contains(token)) score += 1;
    }
    if (score > 0) scored.add((track, score));
  }
  scored.sort((a, b) => b.$2.compareTo(a.$2));
  return [for (final item in scored) item.$1];
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '$minutes:$seconds';
}
