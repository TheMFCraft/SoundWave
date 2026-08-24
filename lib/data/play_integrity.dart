import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('de.cylone.soundwave/integrity');

/// Asks Play Integrity for a token so Play Console can see the API as integrated.
/// The token is not verified on-device (that needs a backend). Failures never block playback.
Future<void> warmUpPlayIntegrity() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    await _channel.invokeMethod<String>('requestIntegrityToken');
  } catch (_) {}
}
