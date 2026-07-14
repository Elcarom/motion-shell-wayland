import 'dart:async';
import 'dart:convert';
import 'dart:io';

class HyprlandEvent {
  const HyprlandEvent(this.name, this.data);

  factory HyprlandEvent.parse(String line) {
    final int separator = line.indexOf('>>');
    if (separator <= 0) {
      return HyprlandEvent('malformed', line);
    }
    return HyprlandEvent(
      line.substring(0, separator),
      line.substring(separator + 2).trimRight(),
    );
  }

  final String name;
  final String data;
}

class HyprlandClient {
  const HyprlandClient({Map<String, String>? environment})
    : _environment = environment;

  final Map<String, String>? _environment;

  Map<String, String> get _env => _environment ?? Platform.environment;

  String? get _basePath {
    final String? runtime = _env['XDG_RUNTIME_DIR'];
    final String? signature = _env['HYPRLAND_INSTANCE_SIGNATURE'];
    if (runtime == null || signature == null) {
      return null;
    }
    return '$runtime/hypr/$signature';
  }

  Stream<HyprlandEvent> events() async* {
    while (true) {
      final String? base = _basePath;
      if (base == null) {
        await Future<void>.delayed(const Duration(seconds: 2));
        continue;
      }
      final InternetAddress address = InternetAddress(
        '$base/.socket2.sock',
        type: InternetAddressType.unix,
      );
      Socket? socket;
      try {
        socket = await Socket.connect(
          address,
          0,
        ).timeout(const Duration(seconds: 2));
        await for (final String line
            in socket.transform(utf8.decoder).transform(const LineSplitter())) {
          yield HyprlandEvent.parse(line);
        }
      } on Object {
        await Future<void>.delayed(const Duration(seconds: 1));
      } finally {
        socket?.destroy();
      }
    }
  }

  Future<Object?> requestJson(String command) async {
    final String response = await request('j/$command');
    return jsonDecode(response);
  }

  Future<String> request(String request) async {
    final String? base = _basePath;
    if (base == null) {
      throw StateError('Hyprland environment is unavailable');
    }
    final InternetAddress address = InternetAddress(
      '$base/.socket.sock',
      type: InternetAddressType.unix,
    );
    final Socket socket = await Socket.connect(
      address,
      0,
    ).timeout(const Duration(seconds: 1));
    try {
      socket.write(request);
      await socket.flush();
      await socket.shutdown(SocketDirection.send);
      return socket
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 2));
    } finally {
      socket.destroy();
    }
  }

  Future<void> dispatch(String dispatcher, [String argument = '']) async {
    final String suffix = argument.isEmpty
        ? dispatcher
        : '$dispatcher $argument';
    final String response = await request('dispatch $suffix');
    if (!response.trim().startsWith('ok')) {
      throw StateError('Hyprland rejected dispatcher: $response');
    }
  }
}
