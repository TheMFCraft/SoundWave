import 'dart:io';

import 'package:path/path.dart' as p;

bool get isAndroid => Platform.isAndroid;
bool get isMacOS => Platform.isMacOS;
bool get isLinux => Platform.isLinux;
bool get isWindows => Platform.isWindows;
bool get isIOS => Platform.isIOS;
bool get isDesktop => isLinux || isWindows || isMacOS;

String? get homeDirectory =>
    Platform.environment[isWindows ? 'USERPROFILE' : 'HOME'];

bool localFileExists(String path) {
  if (path.isEmpty || path.startsWith('jam:')) return false;
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}

List<String> defaultMusicFolders() {
  final home = homeDirectory ?? '';
  if (home.isEmpty) {
    return [
      if (isAndroid) ...[
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
      ],
    ];
  }
  return [
    if (isMacOS || isLinux || isWindows) p.join(home, 'Music'),
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
