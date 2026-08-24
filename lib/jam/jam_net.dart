import 'dart:io';
import 'dart:math';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:path/path.dart' as p;

Future<String?> localIPv4() async {
  try {
    final ip = await NetworkInfo().getWifiIP();
    if (ip != null && ip.isNotEmpty && ip != '0.0.0.0') return ip;
  } catch (_) {}
  try {
    for (final iface in await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    )) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
  } catch (_) {}
  return null;
}

String deviceDisplayName() {
  try {
    final host = Platform.localHostname.trim();
    if (host.isNotEmpty && host != 'localhost') return host;
  } catch (_) {}
  if (Platform.isAndroid) return 'Android';
  if (Platform.isIOS) return 'iPhone';
  if (Platform.isLinux) return 'Linux';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isMacOS) return 'Mac';
  return 'SoundWave';
}

String generatePin() {
  return Random.secure().nextInt(1000000).toString().padLeft(6, '0');
}

String audioContentType(String path) {
  return switch (p.extension(path).toLowerCase()) {
    '.mp3' => 'audio/mpeg',
    '.flac' => 'audio/flac',
    '.wav' => 'audio/wav',
    '.m4a' || '.aac' => 'audio/mp4',
    '.ogg' || '.opus' => 'audio/ogg',
    '.wma' => 'audio/x-ms-wma',
    _ => 'application/octet-stream',
  };
}
