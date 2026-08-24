import 'dart:async';

import 'package:bonsoir/bonsoir.dart';

import 'jam_models.dart';

const jamBonjourType = '_soundwave._tcp';

class JamDiscovery {
  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _sub;
  final found = <String, DiscoveredJam>{};

  void Function()? onChanged;

  Future<void> publish({
    required String name,
    required int port,
    required String sessionId,
    required String playerName,
  }) async {
    await stopPublish();
    final service = BonsoirService(
      name: name,
      type: jamBonjourType,
      port: port,
      attributes: {
        'id': sessionId,
        'player': playerName,
      },
    );
    final broadcast = BonsoirBroadcast(service: service);
    await broadcast.initialize();
    await broadcast.start();
    _broadcast = broadcast;
  }

  Future<void> browse() async {
    await stopBrowse();
    found.clear();
    final discovery = BonsoirDiscovery(type: jamBonjourType);
    await discovery.initialize();
    _sub = discovery.eventStream?.listen((event) {
      switch (event) {
        case BonsoirDiscoveryServiceFoundEvent(:final service):
          discovery.serviceResolver.resolveService(service);
        case BonsoirDiscoveryServiceResolvedEvent(:final service):
          final host = service.hostAddress;
          if (host == null || host.isEmpty) return;
          found[service.name] = DiscoveredJam(
            name: service.attributes['player'] ?? service.name,
            host: host,
            port: service.port,
            sessionId: service.attributes['id'] ?? service.name,
          );
          onChanged?.call();
        case BonsoirDiscoveryServiceLostEvent(:final service):
          found.remove(service.name);
          onChanged?.call();
        default:
          break;
      }
    });
    await discovery.start();
    _discovery = discovery;
  }

  Future<void> stopPublish() async {
    await _broadcast?.stop();
    _broadcast = null;
  }

  Future<void> stopBrowse() async {
    await _sub?.cancel();
    _sub = null;
    await _discovery?.stop();
    _discovery = null;
  }

  Future<void> dispose() async {
    await stopPublish();
    await stopBrowse();
  }
}
