import 'package:flutter_test/flutter_test.dart';
import 'package:soundwave/state/player_controller.dart';

void main() {
  test('remote and content URIs are playable without a local file', () {
    bool missing(String path) => false;

    expect(
      isPlayableTrackUri('https://example.com/track.mp3', fileExists: missing),
      isTrue,
    );
    expect(
      isPlayableTrackUri('http://example.com/track.mp3', fileExists: missing),
      isTrue,
    );
    expect(
      isPlayableTrackUri('content://media/external/audio/media/1', fileExists: missing),
      isTrue,
    );
    expect(isPlayableTrackUri('/missing/song.mp3', fileExists: missing), isFalse);
    expect(isPlayableTrackUri('', fileExists: missing), isFalse);
  });

  test('playbackUriFor keeps stream and content URIs parseable', () {
    expect(
      playbackUriFor('https://cdn.example/a.mp3').scheme,
      'https',
    );
    expect(playbackUriFor('content://media/1').scheme, 'content');
    expect(playbackUriFor('/tmp/song.mp3').scheme, 'file');
  });
}
