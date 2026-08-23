import 'dart:io';

import 'package:path/path.dart' as p;

bool get isAndroid => Platform.isAndroid;
bool get isMacOS => Platform.isMacOS;
bool get isLinux => Platform.isLinux;

String? get homeDirectory => Platform.environment['HOME'];

bool localFileExists(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}

List<String> defaultMusicFolders() {
  final home = homeDirectory ?? '';
  return [
    if (isMacOS || isLinux) p.join(home, 'Music'),
    if (isAndroid) ...[
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
    ],
  ];
}

String joinPath(String a, String b) => p.join(a, b);

Future<String?> writeArtworkBytes(String dir, String id, List<int> bytes) async {
  if (dir.isEmpty) return null;
  final file = File(p.join(dir, '$id.jpg'));
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
