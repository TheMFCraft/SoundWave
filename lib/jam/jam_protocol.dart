import 'dart:convert';

class JamMessage {
  const JamMessage(this.type, [this.data = const {}]);

  final String type;
  final Map<String, dynamic> data;

  String encode() => jsonEncode({'t': type, 'd': data});

  factory JamMessage.decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map) {
      return const JamMessage('unknown');
    }
    final map = Map<String, dynamic>.from(json);
    return JamMessage(
      map['t'] as String? ?? 'unknown',
      Map<String, dynamic>.from(map['d'] as Map? ?? const {}),
    );
  }
}
