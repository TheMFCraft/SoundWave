import 'package:flutter/services.dart';

class JamHotspot {
  static const _channel = MethodChannel('de.cylone.soundwave/jam');

  static Future<({String ssid, String password})?> start() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('startLocalHotspot');
      if (result == null) return null;
      return (
        ssid: result['ssid'] as String? ?? '',
        password: result['password'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopLocalHotspot');
    } catch (_) {}
  }
}
