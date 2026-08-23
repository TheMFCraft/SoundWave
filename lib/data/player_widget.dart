import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';

const _channel = MethodChannel('de.cylone.soundwave/media');

Future<void> syncPlayerWidget({
  required Track? track,
  required bool playing,
}) async {
  if (kIsWeb) return;
  try {
    await _channel.invokeMethod<void>('updatePlayerWidget', {
      'title': track?.title ?? '',
      'artist': track?.artist ?? '',
      'playing': playing && track != null,
      'artworkPath': track?.artworkPath,
      'hasTrack': track != null,
    });
  } catch (_) {}
}
