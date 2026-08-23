import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> readStore() async {
  final file = await _file();
  if (!await file.exists()) return null;
  return file.readAsString();
}

Future<void> writeStore(String contents) async {
  final file = await _file();
  await file.parent.create(recursive: true);
  await file.writeAsString(contents, flush: true);
}

Future<String> artworkDirectoryPath() async {
  final dir = await getApplicationDocumentsDirectory();
  final artwork = Directory('${dir.path}/artwork');
  await artwork.create(recursive: true);
  return artwork.path;
}

Future<File> _file() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/soundwave.json');
}
