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

Future<void> downloadJamFile({
  required String host,
  required int port,
  required String token,
  required String destPath,
  required void Function(int received, int total) onProgress,
}) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('http://$host:$port/file/$token'));
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw HttpException('transfer failed (${response.statusCode})');
    }
    final total = response.contentLength;
    if (total > 100 * 1024 * 1024) {
      throw const HttpException('file too large');
    }
    final file = File(destPath);
    await file.parent.create(recursive: true);
    final sink = file.openWrite();
    var received = 0;
    await for (final chunk in response) {
      received += chunk.length;
      if (received > 100 * 1024 * 1024) {
        await sink.close();
        await file.delete();
        throw const HttpException('file too large');
      }
      sink.add(chunk);
      onProgress(received, total > 0 ? total : received);
    }
    await sink.close();
  } finally {
    client.close(force: true);
  }
}
