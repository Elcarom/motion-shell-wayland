import 'dart:async';

import 'package:flutter/material.dart';

import '../core/ipc/service_client.dart';
import '../core/models/system_snapshot.dart';
import '../core/theme/dynamic_color_service.dart';
import '../integrations/system/system_controls.dart';

class MotionController extends ChangeNotifier {
  MotionController({
    ServiceClient? serviceClient,
    SystemControls? controls,
    DynamicColorService? dynamicColor,
  }) : _serviceClient = serviceClient ?? ServiceClient(),
       _controls = controls ?? const SystemControls(),
       _dynamicColor = dynamicColor ?? const DynamicColorService();

  final ServiceClient _serviceClient;
  final SystemControls _controls;
  final DynamicColorService _dynamicColor;

  StreamSubscription<SystemSnapshot>? _snapshotSubscription;
  SystemSnapshot _snapshot = const SystemSnapshot();
  Color _seed = const Color(DynamicColorService.fallbackSeedArgb);
  ThemeMode _themeMode = ThemeMode.dark;
  bool _reduceMotion = false;
  bool _serviceConnected = false;
  String? _lastError;

  SystemSnapshot get snapshot => _snapshot;
  Color get seed => _seed;
  ThemeMode get themeMode => _themeMode;
  bool get reduceMotion => _reduceMotion;
  bool get serviceConnected => _serviceConnected;
  String? get lastError => _lastError;

  Future<void> initialize({String? wallpaperPath}) async {
    final WallpaperPalette palette = await _dynamicColor.extract(wallpaperPath);
    _seed = Color(palette.seedArgb);
    _serviceConnected = await _serviceClient.connect();
    if (_serviceConnected) {
      _snapshotSubscription = _serviceClient.snapshots.listen(
        _applySnapshot,
        onError: (Object error) {
          _serviceConnected = false;
          _lastError = error.toString();
          notifyListeners();
        },
      );
    } else {
      await refreshLocalSnapshot();
    }
    notifyListeners();
  }

  void _applySnapshot(SystemSnapshot value) {
    _snapshot = value;
    _seed = Color(value.themeSeedArgb);
    _themeMode = switch (value.themeMode) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    _reduceMotion = value.reducedMotion;
    _lastError = null;
    notifyListeners();
  }

  Future<void> refreshLocalSnapshot() async {
    try {
      _snapshot = await _controls.readSnapshot(_snapshot);
      _lastError = null;
    } on Object catch (error) {
      _lastError = error.toString();
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _snapshot = _snapshot.copyWith(themeMode: mode.name);
    notifyListeners();
    unawaited(
      _sendPreference('theme.mode', <String, Object?>{'mode': mode.name}),
    );
  }

  void setReducedMotion(bool value) {
    _reduceMotion = value;
    _snapshot = _snapshot.copyWith(reducedMotion: value);
    notifyListeners();
    unawaited(
      _sendPreference('accessibility.reducedMotion', <String, Object?>{
        'enabled': value,
      }),
    );
  }

  Future<void> setWallpaper(String path) async {
    final WallpaperPalette palette = await _dynamicColor.extract(path);
    _seed = Color(palette.seedArgb);
    _snapshot = _snapshot.copyWith(
      wallpaperPath: path,
      themeSeedArgb: palette.seedArgb,
    );
    notifyListeners();
    if (_serviceConnected) {
      try {
        await _serviceClient.call('appearance.wallpaper', <String, Object?>{
          'path': path,
        });
      } on Object catch (error) {
        _lastError = error.toString();
        notifyListeners();
      }
    }
  }

  Future<void> _sendPreference(
    String method,
    Map<String, Object?> params,
  ) async {
    if (!_serviceConnected) {
      return;
    }
    try {
      await _serviceClient.call(method, params);
    } on Object catch (error) {
      _lastError = error.toString();
      notifyListeners();
    }
  }

  void setDoNotDisturb(bool value) {
    _snapshot = _snapshot.copyWith(doNotDisturb: value);
    notifyListeners();
    unawaited(_sendPreference('dnd.set', <String, Object?>{'enabled': value}));
  }

  Future<void> setWifi(bool value) async {
    await _optimistic(
      pending: _snapshot.copyWith(wifi: AvailabilityState.loading),
      action: () async {
        if (_serviceConnected) {
          await _serviceClient.call('wifi.set', <String, Object?>{
            'enabled': value,
          });
        } else {
          await _controls.setWifi(value);
        }
      },
      success: _snapshot.copyWith(
        wifi: value ? AvailabilityState.enabled : AvailabilityState.disabled,
      ),
    );
  }

  Future<void> setBluetooth(bool value) async {
    await _optimistic(
      pending: _snapshot.copyWith(bluetooth: AvailabilityState.loading),
      action: () async {
        if (_serviceConnected) {
          await _serviceClient.call('bluetooth.set', <String, Object?>{
            'enabled': value,
          });
        } else {
          await _controls.setBluetooth(value);
        }
      },
      success: _snapshot.copyWith(
        bluetooth: value
            ? AvailabilityState.enabled
            : AvailabilityState.disabled,
      ),
    );
  }

  Future<void> setVolume(double value) => setOutputVolume(value);

  Future<void> setOutputVolume(double value) async {
    final AudioEndpointSnapshot before = _snapshot.outputAudio;
    _snapshot = _snapshot.copyWith(
      outputAudio: before.copyWith(volume: value, muted: false),
    );
    notifyListeners();
    try {
      final String? deviceId = before.selectedDeviceId;
      if (_serviceConnected) {
        await _serviceClient.call('audio.output.volume.set', <String, Object?>{
          'value': value,
          'deviceId': deviceId,
        });
      } else {
        await _controls.setOutputVolume(value, deviceId: deviceId);
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(outputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> setInputVolume(double value) async {
    final AudioEndpointSnapshot before = _snapshot.inputAudio;
    _snapshot = _snapshot.copyWith(
      inputAudio: before.copyWith(volume: value, muted: false),
    );
    notifyListeners();
    try {
      final String? deviceId = before.selectedDeviceId;
      if (_serviceConnected) {
        await _serviceClient.call('audio.input.volume.set', <String, Object?>{
          'value': value,
          'deviceId': deviceId,
        });
      } else {
        await _controls.setInputVolume(value, deviceId: deviceId);
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(inputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> setOutputDevice(String deviceId) async {
    final AudioEndpointSnapshot before = _snapshot.outputAudio;
    _snapshot = _snapshot.copyWith(outputAudio: before.selecting(deviceId));
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('audio.output.device.set', <String, Object?>{
          'deviceId': deviceId,
        });
      } else {
        await _controls.setOutputDevice(deviceId);
        _snapshot = await _controls.readSnapshot(_snapshot);
        notifyListeners();
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(outputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> setInputDevice(String deviceId) async {
    final AudioEndpointSnapshot before = _snapshot.inputAudio;
    _snapshot = _snapshot.copyWith(inputAudio: before.selecting(deviceId));
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('audio.input.device.set', <String, Object?>{
          'deviceId': deviceId,
        });
      } else {
        await _controls.setInputDevice(deviceId);
        _snapshot = await _controls.readSnapshot(_snapshot);
        notifyListeners();
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(inputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleOutputMute() async {
    final AudioEndpointSnapshot before = _snapshot.outputAudio;
    _snapshot = _snapshot.copyWith(
      outputAudio: before.copyWith(muted: !before.muted),
    );
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('audio.output.mute.toggle', <String, Object?>{
          'deviceId': before.selectedDeviceId,
        });
      } else {
        await _controls.toggleOutputMute(deviceId: before.selectedDeviceId);
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(outputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> toggleInputMute() async {
    final AudioEndpointSnapshot before = _snapshot.inputAudio;
    _snapshot = _snapshot.copyWith(
      inputAudio: before.copyWith(muted: !before.muted),
    );
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('audio.input.mute.toggle', <String, Object?>{
          'deviceId': before.selectedDeviceId,
        });
      } else {
        await _controls.toggleInputMute(deviceId: before.selectedDeviceId);
      }
    } on Object catch (error) {
      _snapshot = _snapshot.copyWith(inputAudio: before);
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> setBrightness(double value) async {
    _snapshot = _snapshot.copyWith(brightness: value);
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('brightness.set', <String, Object?>{
          'value': value,
        });
      } else {
        await _controls.setBrightness(value);
      }
    } on Object catch (error) {
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> setPowerProfile(String value) async {
    _snapshot = _snapshot.copyWith(powerProfile: value);
    notifyListeners();
    try {
      if (_serviceConnected) {
        await _serviceClient.call('powerProfile.set', <String, Object?>{
          'value': value,
        });
      } else {
        await _controls.setPowerProfile(value);
      }
    } on Object catch (error) {
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<String?> takeScreenshot() async {
    try {
      if (_serviceConnected) {
        final Object? result = await _serviceClient.call('screenshot.region');
        if (result is Map && result['path'] is String) {
          return result['path'] as String;
        }
        return null;
      }
      return await _controls.screenshot();
    } on Object catch (error) {
      _lastError = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> sessionAction(String action) async {
    if (_serviceConnected) {
      await _serviceClient.call('session.$action');
      return;
    }
    switch (action) {
      case 'lock':
        await _controls.lock();
        return;
      case 'suspend':
        await _controls.suspend();
        return;
      case 'hibernate':
        await _controls.hibernate();
        return;
      case 'logout':
        await _controls.logOut();
        return;
      case 'reboot':
        await _controls.reboot();
        return;
      case 'poweroff':
        await _controls.powerOff();
        return;
    }
  }

  Future<void> _optimistic({
    required SystemSnapshot pending,
    required Future<void> Function() action,
    required SystemSnapshot success,
  }) async {
    final SystemSnapshot before = _snapshot;
    _snapshot = pending;
    _lastError = null;
    notifyListeners();
    try {
      await action();
      _snapshot = success;
    } on Object catch (error) {
      _snapshot = before;
      _lastError = error.toString();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_snapshotSubscription?.cancel());
    unawaited(_serviceClient.close());
    super.dispose();
  }
}
