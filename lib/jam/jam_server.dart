import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'jam_protocol.dart';

class JamServer {
  HttpServer? _server;
  final _sockets = <String, WebSocketChannel>{};
  final _memberOfSocket = <String, String>{};
  void Function(String socketId, JamMessage message)? onMessage;
  void Function(String socketId, String? memberId)? onDisconnect;
  Future<String?> Function(String token, Stream<List<int>> body, int? length)? onUpload;

  int get port => _server?.port ?? 0;
  bool get isRunning => _server != null;

  Future<int> start() async {
    final router = Router()
      ..get(
        '/ws',
        webSocketHandler(
          (WebSocketChannel socket, String? _) {
            final id = const Uuid().v4();
            _sockets[id] = socket;
            socket.stream.listen(
              (raw) {
                if (raw is! String) return;
                onMessage?.call(id, JamMessage.decode(raw));
              },
              onDone: () => _drop(id),
              onError: (_) => _drop(id),
              cancelOnError: true,
            );
          },
          pingInterval: const Duration(seconds: 20),
        ),
      )
      ..get('/health', (_) => Response.ok('ok'))
      ..put('/upload/<token>', (Request request, String token) async {
        if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(token)) {
          return Response.badRequest(body: 'bad token');
        }
        final handler = onUpload;
        if (handler == null) return Response.forbidden('no upload');
        try {
          final path = await handler(token, request.read(), request.contentLength);
          if (path == null) return Response.notFound('unknown token');
          return Response.ok('ok');
        } catch (_) {
          return Response.internalServerError(body: 'upload failed');
        }
      });

    _server = await io.serve(router.call, InternetAddress.anyIPv4, 0);
    return _server!.port;
  }

  void bindMember(String socketId, String memberId) {
    _memberOfSocket[socketId] = memberId;
  }

  String? memberIdFor(String socketId) => _memberOfSocket[socketId];

  void sendToSocket(String socketId, JamMessage message) {
    _sockets[socketId]?.sink.add(message.encode());
  }

  void sendToMember(String memberId, JamMessage message) {
    for (final entry in _memberOfSocket.entries) {
      if (entry.value == memberId) {
        sendToSocket(entry.key, message);
        return;
      }
    }
  }

  void broadcast(JamMessage message) {
    final encoded = message.encode();
    for (final socket in _sockets.values) {
      socket.sink.add(encoded);
    }
  }

  Future<void> close() async {
    for (final socket in _sockets.values) {
      await socket.sink.close();
    }
    _sockets.clear();
    _memberOfSocket.clear();
    await _server?.close(force: true);
    _server = null;
  }

  void _drop(String socketId) {
    final memberId = _memberOfSocket.remove(socketId);
    _sockets.remove(socketId);
    onDisconnect?.call(socketId, memberId);
  }
}
