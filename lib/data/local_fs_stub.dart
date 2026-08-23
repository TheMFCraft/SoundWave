import 'package:path/path.dart' as p;

bool get isAndroid => false;
bool get isMacOS => false;
bool get isLinux => false;

String? get homeDirectory => null;

bool localFileExists(String path) => false;

List<String> defaultMusicFolders() => const [];

String joinPath(String a, String b) => p.join(a, b);

Future<String?> writeArtworkBytes(String dir, String id, List<int> bytes) async => null;
