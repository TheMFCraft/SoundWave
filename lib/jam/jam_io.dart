import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/local_fs.dart';
import '../data/models.dart';
import 'jam_models.dart';

const _media = MethodChannel('de.cylone.soundwave/media');

bool canOfferTrack(Track track) {
  final uri = track.uri;
  if (uri.isEmpty || isJamCatalogTrack(track) || uri.startsWith('jam:')) {
    return false;
  }
  if (localFileExists(uri)) return true;
  if (isAndroid &&
      (uri.startsWith('content:') || uri.startsWith('/') || uri.startsWith('file:'))) {
    return true;
  }
  return false;
}

Future<String?> resolveTrackPathForUpload(Track track) async {
  if (localFileExists(track.uri)) return track.uri;
  if (!isAndroid || !canOfferTrack(track)) return null;
  try {
    final root = await getTemporaryDirectory();
    final dest = p.join(
      root.path,
      'jam_offer',
      '${track.id}${jamFileExtension(track.uri)}',
    );
    final ok = await _media.invokeMethod<bool>('copyAudioToPath', {
      'src': track.uri,
      'dest': dest,
    });
    if (ok == true && File(dest).existsSync()) return dest;
  } catch (_) {}
  return null;
}
