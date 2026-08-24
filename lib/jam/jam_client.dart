import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'jam_net.dart';
import 'jam_protocol.dart';

class JamClient {
  WebSocketChannel? _socket;
  HttpServer? _files;
  StreamSubscription<dynamic>? _sub;
  final offered = <String, String>{};

  void Function(JamMessage message)? onMessage;
  void Function()? onClosed;

  int get filePort => _files?.port ?? 0;
  bool get isConnected => _socket != null;

  Future<int> startFileServer() async {
    final router = Router()
      ..get('/file/<token>', (Request request, String token) async {
        final path = offered[token];
        if (path == null || !File(path).existsSync()) {
          return Response.notFound('missing');
        }
        final file = File(path);
        final length = await file.length();
        return Response.ok(
          file.openRead(),
          headers: {
            'Content-Type': audioContentType(path),
            'Content-Length': '$length',
          },
        );
      });
    _files = await io.serve(router.call, InternetAddress.anyIPv4, 0);
    return _files!.port;
  }

  void offer(String token, String path) => offered[token] = path;

  Future<void> connect(String host, int port) async {
    final socket = IOWebSocketChannel.connect(
      Uri.parse('ws://$host:$port/ws'),
      pingInterval: const Duration(seconds: 20),
    );
    _socket = socket;
    _sub = socket.stream.listen(
      (raw) {
        if (raw is! String) return;
        onMessage?.call(JamMessage.decode(raw));
      },
      onDone: () {
        onClosed?.call();
      },
      onError: (_) {
        onClosed?.call();
      },
      cancelOnError: true,
    );
  }

  void send(JamMessage message) {
    _socket?.sink.add(message.encode());
  }

  Future<void> close() async {
    await _sub?.cancel();
    _sub = null;
    await _socket?.sink.close();
    _socket = null;
    offered.clear();
    await _files?.close(force: true);
    _files = null;
  }
}

Future<void> uploadJamFile({
  required String host,
  required int port,
  required String token,
  required String path,
}) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw const FileSystemException('missing file');
  }
  final length = await file.length();
  if (length <= 0) throw const HttpException('empty file');
  if (length > 100 * 1024 * 1024) {
    throw const HttpException('file too large');
  }
  final client = HttpClient();
  try {
    final request = await client.putUrl(
      Uri(scheme: 'http', host: host, port: port, path: '/upload/$token'),
    );
    request.headers.contentType = ContentType('application', 'octet-stream');
    request.contentLength = length;
    await request.addStream(file.openRead());
    final response = await request.close().timeout(const Duration(minutes: 5));
    if (response.statusCode != 200) {
      throw HttpException('upload failed (${response.statusCode})');
    }
    await response.drain<void>();
  } finally {
    client.close(force: true);
  }
}
