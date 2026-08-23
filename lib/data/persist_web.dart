import 'package:shared_preferences/shared_preferences.dart';

const _key = 'soundwave_db';

Future<String?> readStore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_key);
}

Future<void> writeStore(String contents) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, contents);
}

Future<String> artworkDirectoryPath() async => '';
