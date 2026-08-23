import 'package:flutter_test/flutter_test.dart';
import 'package:soundwave/data/catalog.dart';
import 'package:soundwave/data/models.dart';

void main() {
  test('search ranks title hits first', () {
    final tracks = [
      Track(id: '1', title: 'Night Drive', artist: 'Home', album: 'Odyssey', uri: 'a', addedAt: DateTime(2026)),
      Track(id: '2', title: 'Pulse', artist: 'Night Drive', album: 'Live', uri: 'b', addedAt: DateTime(2026)),
    ];
    final results = searchTracks(tracks, 'night drive');
    expect(results.first.id, '1');
  });

  test('mood matching uses genre tags', () {
    final focus = Track(
      id: '1',
      title: 'Study',
      artist: 'A',
      album: 'B',
      uri: 'a',
      genre: 'Ambient',
      addedAt: DateTime(2026),
    );
    expect(trackMatchesMood(focus, Mood.focus), isTrue);
    expect(trackMatchesGenre(focus, 'electronic'), isFalse);
  });

  test('track json roundtrip keeps likes and plays', () {
    final track = Track(
      id: 'x',
      title: 'Neon',
      artist: 'Collective',
      album: 'Horizons',
      uri: '/tmp/a.mp3',
      liked: true,
      playCount: 4,
      addedAt: DateTime.utc(2026, 1, 2),
    );
    final copy = Track.fromJson(track.toJson());
    expect(copy.liked, isTrue);
    expect(copy.playCount, 4);
    expect(copy.title, 'Neon');
  });
}
