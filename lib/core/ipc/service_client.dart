import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/system_snapshot.dart';

class ServiceClient {
  ServiceClient({String? socketPath}) : socketPath = socketPath ?? defaultPath;

  static String get defaultPath {
    final String runtime = Platform.environment['XDG_RUNTIME_DIR'] ?? '/tmp';
    return '$runtime/motion-shell/state.sock';
  }

  final String socketPath;
  Socket? _socket;
  StreamSubscription<String>? _subscription;
  final StreamController<SystemSnapshot> _snapshots =
      StreamController<SystemSnapshot>.broadcast();
  final Map<int, Completer<Object?>> _pending = <int, Completer<Object?>>{};
  int _nextRequestId = 1;

  Stream<SystemSnapshot> get snapshots => _snapshots.stream;

  Future<bool> connect() async {
    try {
      final InternetAddress address = InternetAddress(
        socketPath,
        type: InternetAddressType.unix,
      );
      _socket = await Socket.connect(
        address,
        0,
      ).timeout(const Duration(milliseconds: 600));
      _subscription = _socket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleLine,
            onDone: _handleDisconnect,
            onError: (_) => _handleDisconnect(),
          );
      await call('subscribe');
      return true;
    } on Object {
      await close();
      return false;
    }
  }

  Future<Object?> call(
    String method, [
    Map<String, Object?> params = const <String, Object?>{},
  ]) async {
    final Socket? socket = _socket;
    if (socket == null) {
      throw StateError('Motion state service is disconnected');
    }
    final int id = _nextRequestId++;
    final Completer<Object?> completer = Completer<Object?>();
    _pending[id] = completer;
    try {
      socket.writeln(
        jsonEncode(<String, Object?>{
          'id': id,
          'method': method,
          'params': params,
        }),
      );
      await socket.flush();
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _pending.remove(id);
          throw TimeoutException('State service request timed out: $method');
        },
      );
    } on Object {
      _pending.remove(id);
      rethrow;
    }
  }

  void _handleLine(String line) {
    try {
      final Object? decodedValue = jsonDecode(line);
      if (decodedValue is! Map) {
        return;
      }
      final Map<String, Object?> decoded = Map<String, Object?>.from(
        decodedValue,
      );
      if (decoded['event'] == 'snapshot' && decoded['data'] is Map) {
        _snapshots.add(
          SystemSnapshot.fromJson(
            Map<String, Object?>.from(decoded['data']! as Map),
          ),
        );
        return;
      }
      final int? id = (decoded['id'] as num?)?.toInt();
      if (id == null) {
        return;
      }
      final Completer<Object?>? completer = _pending.remove(id);
      if (completer == null) {
        return;
      }
      if (decoded['error'] is Map) {
        final Map<String, Object?> error = Map<String, Object?>.from(
          decoded['error']! as Map,
        );
        completer.completeError(
          StateError(error['message'] as String? ?? 'State service error'),
        );
      } else {
        completer.complete(decoded['result']);
      }
    } on Object {
      // A malformed local frame is ignored; subsequent frames remain usable.
    }
  }

  void _handleDisconnect() {
    _socket = null;
    final StateError error = StateError('Motion state service disconnected');
    for (final Completer<Object?> completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pending.clear();
  }

  Future<void> close() async {
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _handleDisconnect();
  }
}
