import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:motion_shell/core/ipc/service_client.dart';
import 'package:motion_shell/core/models/system_snapshot.dart';
import 'package:motion_shell/core/theme/dynamic_color_service.dart';
import 'package:motion_shell/integrations/hyprland/hyprland_client.dart';
import 'package:motion_shell/integrations/system/system_controls.dart';

Future<void> main() async {
  final MotionStateService service = MotionStateService();
  ProcessSignal.sigterm.watch().listen((_) => service.close());
  ProcessSignal.sigint.watch().listen((_) => service.close());
  await service.run();
}

class MotionStateService {
  MotionStateService({
    this.controls = const SystemControls(),
    this.hyprland = const HyprlandClient(),
    this.dynamicColor = const DynamicColorService(),
  });

  final SystemControls controls;
  final HyprlandClient hyprland;
  final DynamicColorService dynamicColor;
  final Set<Socket> _clients = <Socket>{};
  final Set<Socket> _subscribers = <Socket>{};
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];
  SystemSnapshot _snapshot = const SystemSnapshot();
  ServerSocket? _server;
  Timer? _pollTimer;
  bool _closing = false;

  Future<void> run() async {
    final File socketFile = File(ServiceClient.defaultPath);
    await socketFile.parent.create(recursive: true);
    if (await socketFile.exists()) {
      await socketFile.delete();
    }
    await Process.run('chmod', <String>['700', socketFile.parent.path]);
    final InternetAddress address = InternetAddress(
      socketFile.path,
      type: InternetAddressType.unix,
    );
    _server = await ServerSocket.bind(address, 0, shared: false);
    await Process.run('chmod', <String>['600', socketFile.path]);
    _server!.listen(_accept, onError: _logError);

    await _loadPreferences();
    await _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _poll());
    _subscriptions.add(
      hyprland.events().listen(
        _handleHyprlandEvent,
        onError: _logError,
      ),
    );

    await Completer<void>().future;
  }

  void _accept(Socket socket) {
    _clients.add(socket);
    final StreamSubscription<String> subscription = socket
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (String line) => _handleRequest(socket, line),
      onDone: () => _remove(socket),
      onError: (_) => _remove(socket),
    );
    _subscriptions.add(subscription);
  }

  Future<void> _handleRequest(Socket socket, String line) async {
    Object? id;
    try {
      final Object? value = jsonDecode(line);
      if (value is! Map) {
        throw const FormatException('Request must be an object');
      }
      final Map<String, Object?> request = Map<String, Object?>.from(value);
      id = request['id'];
      final String method = request['method'] as String? ?? '';
      final Map<String, Object?> params = request['params'] is Map
          ? Map<String, Object?>.from(request['params']! as Map)
          : const <String, Object?>{};
      final Object? result = await _dispatch(socket, method, params);
      socket.writeln(jsonEncode(<String, Object?>{'id': id, 'result': result}));
    } on Object catch (error) {
      socket.writeln(
        jsonEncode(<String, Object?>{
          'id': id,
          'error': <String, Object?>{
            'code': 'request_failed',
            'message': error.toString(),
          },
        }),
      );
    }
  }

  Future<Object?> _dispatch(
    Socket socket,
    String method,
    Map<String, Object?> params,
  ) async {
    switch (method) {
      case 'subscribe':
        _subscribers.add(socket);
        _sendSnapshot(socket);
        return <String, Object?>{'subscribed': true};
      case 'snapshot.get':
        return _snapshot.toJson();
      case 'wifi.set':
        await controls.setWifi(params['enabled'] == true);
        await _poll();
        return null;
      case 'bluetooth.set':
        await controls.setBluetooth(params['enabled'] == true);
        await _poll();
        return null;
      case 'volume.set':
      case 'audio.output.volume.set':
        await controls.setOutputVolume(
          (params['value'] as num).toDouble(),
          deviceId: _validatedAudioDevice(
            params['deviceId'],
            _snapshot.outputAudio.devices,
          ),
        );
        await _poll();
        return null;
      case 'audio.input.volume.set':
        await controls.setInputVolume(
          (params['value'] as num).toDouble(),
          deviceId: _validatedAudioDevice(
            params['deviceId'],
            _snapshot.inputAudio.devices,
          ),
        );
        await _poll();
        return null;
      case 'audio.output.device.set':
        final String outputId = params['deviceId'] as String;
        _requireAudioDevice(outputId, _snapshot.outputAudio.devices);
        await controls.setOutputDevice(outputId);
        await _poll();
        return null;
      case 'audio.input.device.set':
        final String inputId = params['deviceId'] as String;
        _requireAudioDevice(inputId, _snapshot.inputAudio.devices);
        await controls.setInputDevice(inputId);
        await _poll();
        return null;
      case 'audio.output.mute.toggle':
        await controls.toggleOutputMute(
          deviceId: _validatedAudioDevice(
            params['deviceId'],
            _snapshot.outputAudio.devices,
          ),
        );
        await _poll();
        return null;
      case 'audio.input.mute.toggle':
        await controls.toggleInputMute(
          deviceId: _validatedAudioDevice(
            params['deviceId'],
            _snapshot.inputAudio.devices,
          ),
        );
        await _poll();
        return null;
      case 'brightness.set':
        await controls.setBrightness((params['value'] as num).toDouble());
        await _poll();
        return null;
      case 'powerProfile.set':
        await controls.setPowerProfile(params['value'] as String);
        await _poll();
        return null;
      case 'dnd.set':
        _snapshot = _snapshot.copyWith(doNotDisturb: params['enabled'] == true);
        await _persistAndBroadcast();
        return null;
      case 'theme.mode':
        final String mode = params['mode'] as String? ?? 'dark';
        if (!const <String>{'system', 'light', 'dark'}.contains(mode)) {
          throw ArgumentError.value(mode, 'mode', 'Unsupported theme mode');
        }
        _snapshot = _snapshot.copyWith(themeMode: mode);
        await _persistAndBroadcast();
        return null;
      case 'accessibility.reducedMotion':
        _snapshot = _snapshot.copyWith(
          reducedMotion: params['enabled'] == true,
        );
        await _persistAndBroadcast();
        return null;
      case 'appearance.wallpaper':
        final String path = params['path'] as String? ?? '';
        if (path.isEmpty || !await File(path).exists()) {
          throw ArgumentError.value(path, 'path', 'Wallpaper does not exist');
        }
        final WallpaperPalette palette = await dynamicColor.extract(path);
        _snapshot = _snapshot.copyWith(
          wallpaperPath: path,
          themeSeedArgb: palette.seedArgb,
        );
        await _persistAndBroadcast();
        return <String, Object?>{'seedArgb': palette.seedArgb};
      case 'screenshot.region':
        return <String, Object?>{'path': await controls.screenshot()};
      case 'session.lock':
        await controls.lock();
        return null;
      case 'session.suspend':
        await controls.suspend();
        return null;
      case 'session.hibernate':
        await controls.hibernate();
        return null;
      case 'session.logout':
        await controls.logOut();
        return null;
      case 'session.reboot':
        await controls.reboot();
        return null;
      case 'session.poweroff':
        await controls.powerOff();
        return null;
      default:
        throw UnsupportedError('Unknown method: $method');
    }
  }


  String? _validatedAudioDevice(
    Object? rawId,
    List<AudioDevice> devices,
  ) {
    if (rawId == null) {
      return null;
    }
    final String id = rawId as String;
    _requireAudioDevice(id, devices);
    return id;
  }

  void _requireAudioDevice(String id, List<AudioDevice> devices) {
    if (devices.any((AudioDevice device) => device.id == id)) {
      return;
    }
    throw ArgumentError.value(id, 'deviceId', 'Unknown audio device');
  }

  Future<void> _poll() async {
    if (_closing) {
      return;
    }
    try {
      _snapshot = await controls.readSnapshot(_snapshot);
      _broadcast();
    } on Object catch (error) {
      _logError(error);
    }
  }

  void _handleHyprlandEvent(HyprlandEvent event) {
    switch (event.name) {
      case 'workspace':
        _snapshot = _snapshot.copyWith(workspace: event.data);
        break;
      case 'workspacev2':
        final List<String> fields = event.data.split(',');
        if (fields.length >= 2) {
          _snapshot = _snapshot.copyWith(workspace: fields[1]);
        }
        break;
      case 'activewindow':
        final int comma = event.data.indexOf(',');
        _snapshot = _snapshot.copyWith(
          activeApplication:
              comma >= 0 ? event.data.substring(comma + 1) : event.data,
        );
        break;
      case 'screencast':
      case 'screencastv2':
        _snapshot = _snapshot.copyWith(
          screenRecording: event.data.startsWith('1,'),
        );
        break;
      default:
        return;
    }
    _broadcast();
  }

  void _sendSnapshot(Socket socket) {
    socket.writeln(
      jsonEncode(<String, Object?>{
        'event': 'snapshot',
        'data': _snapshot.toJson(),
      }),
    );
  }

  void _broadcast() {
    for (final Socket socket in List<Socket>.of(_subscribers)) {
      try {
        _sendSnapshot(socket);
      } on Object {
        _remove(socket);
      }
    }
  }

  Future<void> _persistAndBroadcast() async {
    await _writePreferences();
    _broadcast();
  }

  File get _preferencesFile {
    final String home = Platform.environment['HOME'] ?? '/tmp';
    final String stateHome =
        Platform.environment['XDG_STATE_HOME'] ?? '$home/.local/state';
    return File('$stateHome/motion-shell/preferences.json');
  }

  Future<void> _loadPreferences() async {
    final File file = _preferencesFile;
    Map<String, Object?> values = <String, Object?>{};
    if (await file.exists()) {
      try {
        final Object? decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) {
          values = Map<String, Object?>.from(decoded);
        }
      } on Object catch (error) {
        _logError('Ignoring corrupt preferences: $error');
      }
    }
    final String home = Platform.environment['HOME'] ?? '/tmp';
    final String bundledWallpaper =
        '$home/.local/share/motion-shell/wallpaper.png';
    final String? wallpaperPath = values['wallpaperPath'] as String? ??
        (await File(bundledWallpaper).exists() ? bundledWallpaper : null);
    final WallpaperPalette palette = await dynamicColor.extract(wallpaperPath);
    final String storedMode = values['themeMode'] as String? ?? 'dark';
    final String themeMode =
        const <String>{'system', 'light', 'dark'}.contains(storedMode)
            ? storedMode
            : 'dark';
    _snapshot = _snapshot.copyWith(
      doNotDisturb: values['doNotDisturb'] as bool? ?? false,
      themeSeedArgb: palette.seedArgb,
      themeMode: themeMode,
      reducedMotion: values['reducedMotion'] as bool? ?? false,
      wallpaperPath: wallpaperPath,
    );
    await _writePreferences();
  }

  Future<void> _writePreferences() async {
    final File file = _preferencesFile;
    await file.parent.create(recursive: true);
    final Map<String, Object?> preferences = <String, Object?>{
      'doNotDisturb': _snapshot.doNotDisturb,
      'themeMode': _snapshot.themeMode,
      'reducedMotion': _snapshot.reducedMotion,
      'wallpaperPath': _snapshot.wallpaperPath,
      'themeSeedArgb': _snapshot.themeSeedArgb,
    };
    final File temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(preferences),
      flush: true,
    );
    if (await file.exists()) {
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  void _remove(Socket socket) {
    _clients.remove(socket);
    _subscribers.remove(socket);
    socket.destroy();
  }

  void _logError(Object error) {
    stderr.writeln('[motion-service] $error');
  }

  Future<void> close() async {
    if (_closing) {
      return;
    }
    _closing = true;
    _pollTimer?.cancel();
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      await subscription.cancel();
    }
    for (final Socket socket in _clients) {
      socket.destroy();
    }
    await _server?.close();
    final File socketFile = File(ServiceClient.defaultPath);
    if (await socketFile.exists()) {
      await socketFile.delete();
    }
    exit(0);
  }
}
