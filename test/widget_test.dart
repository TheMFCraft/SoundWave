import 'package:flutter_test/flutter_test.dart';
import 'package:soundwave/data/catalog.dart';
import 'package:soundwave/data/models.dart';
import 'package:soundwave/jam/jam_match.dart';
import 'package:soundwave/jam/jam_models.dart';
import 'package:soundwave/jam/jam_protocol.dart';

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

  test('jam protocol roundtrip', () {
    const message = JamMessage('join', {'pin': '123456', 'host': '192.168.1.8'});
    final parsed = JamMessage.decode(message.encode());
    expect(parsed.type, 'join');
    expect(parsed.data['pin'], '123456');
    expect(parsed.data['host'], '192.168.1.8');
  });

  test('local match uses title artist and duration', () {
    final library = [
      Track(
        id: 'local',
        title: 'Midnight Drive',
        artist: 'Nova',
        album: 'Night',
        uri: '/music/a.mp3',
        durationMs: 183400,
        addedAt: DateTime(2026),
      ),
    ];
    expect(
      findLocalMatch(library, title: 'midnight drive', artist: 'Nova', durationMs: 183000)?.id,
      'local',
    );
    expect(
      jamNeedsTransfer(library: library, title: 'Other', artist: 'Nova', durationMs: 183400),
      isTrue,
    );
  });

  test('join info parses uri and host port pin', () {
    final fromUri = JamJoinInfo.tryParse('soundwave://jam?h=10.0.0.4&p=47831&c=042001');
    expect(fromUri?.host, '10.0.0.4');
    expect(fromUri?.port, 47831);
    expect(fromUri?.pin, '042001');
    final fromText = JamJoinInfo.tryParse('192.168.1.9:9000 111222');
    expect(fromText?.host, '192.168.1.9');
    expect(fromText?.port, 9000);
    expect(fromText?.pin, '111222');
  });
}
