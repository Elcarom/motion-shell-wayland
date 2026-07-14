import 'dart:io';
import 'dart:math' as math;

import '../../core/models/system_snapshot.dart';
import '../../core/platform/process_runner.dart';
import '../audio/wpctl_parser.dart';

class SystemControls {
  const SystemControls({this.runner = const SafeProcessRunner()});

  final SafeProcessRunner runner;

  Future<SystemSnapshot> readSnapshot(SystemSnapshot previous) async {
    AvailabilityState wifi = AvailabilityState.unavailable;
    AvailabilityState bluetooth = AvailabilityState.unavailable;
    AudioEndpointSnapshot outputAudio = previous.outputAudio;
    AudioEndpointSnapshot inputAudio = previous.inputAudio;
    double brightness = previous.brightness;
    String powerProfile = previous.powerProfile;

    if (await runner.exists('nmcli')) {
      final ProcessResultValue result = await runner.run(
        'nmcli',
        <String>['-t', '-f', 'WIFI', 'general'],
        check: false,
      );
      wifi = result.stdout.trim() == 'enabled'
          ? AvailabilityState.enabled
          : AvailabilityState.disabled;
    }
    if (await runner.exists('bluetoothctl')) {
      final ProcessResultValue result = await runner.run(
        'bluetoothctl',
        <String>['show'],
        check: false,
      );
      bluetooth = result.stdout.contains('Powered: yes')
          ? AvailabilityState.enabled
          : AvailabilityState.disabled;
    }
    if (await runner.exists('wpctl')) {
      final ProcessResultValue status = await runner.run(
        'wpctl',
        const <String>['status'],
        check: false,
      );
      final WpctlAudioCatalog catalog = status.succeeded
          ? WpctlParser.parseStatus(status.stdout)
          : const WpctlAudioCatalog();
      outputAudio = await _readAudioEndpoint(
        previous: previous.outputAudio,
        target: '@DEFAULT_AUDIO_SINK@',
        devices: catalog.outputs,
      );
      inputAudio = await _readAudioEndpoint(
        previous: previous.inputAudio,
        target: '@DEFAULT_AUDIO_SOURCE@',
        devices: catalog.inputs,
      );
    } else {
      outputAudio = previous.outputAudio.copyWith(
        availability: AvailabilityState.unavailable,
        devices: const <AudioDevice>[],
        clearSelectedDeviceId: true,
      );
      inputAudio = previous.inputAudio.copyWith(
        availability: AvailabilityState.unavailable,
        devices: const <AudioDevice>[],
        clearSelectedDeviceId: true,
      );
    }
    if (await runner.exists('brightnessctl')) {
      final ProcessResultValue result = await runner.run(
        'brightnessctl',
        <String>['-m'],
        check: false,
      );
      final RegExpMatch? match = RegExp(r',([0-9]+)%').firstMatch(result.stdout);
      brightness =
          (double.tryParse(match?.group(1) ?? '') ?? brightness * 100) / 100;
    }
    if (await runner.exists('powerprofilesctl')) {
      final ProcessResultValue result = await runner.run(
        'powerprofilesctl',
        <String>['get'],
        check: false,
      );
      if (result.succeeded && result.stdout.trim().isNotEmpty) {
        powerProfile = result.stdout.trim();
      }
    }
    return previous.copyWith(
      wifi: wifi,
      bluetooth: bluetooth,
      outputAudio: outputAudio,
      inputAudio: inputAudio,
      brightness: brightness.clamp(0, 1).toDouble(),
      powerProfile: powerProfile,
    );
  }

  Future<AudioEndpointSnapshot> _readAudioEndpoint({
    required AudioEndpointSnapshot previous,
    required String target,
    required List<AudioDevice> devices,
  }) async {
    final ProcessResultValue result = await runner.run(
      'wpctl',
      <String>['get-volume', target],
      check: false,
    );
    if (!result.succeeded) {
      return previous.copyWith(
        availability: AvailabilityState.error,
        devices: devices,
      );
    }
    final ({double volume, bool muted}) parsed = WpctlParser.parseVolume(
      result.stdout,
      fallback: previous.volume,
    );
    final List<AudioDevice> effectiveDevices = devices.isEmpty
        ? <AudioDevice>[
            AudioDevice(
              id: target,
              name: target.contains('SINK')
                  ? 'Default output'
                  : 'Default input',
              isDefault: true,
            ),
          ]
        : devices;
    String? selectedId;
    for (final AudioDevice device in effectiveDevices) {
      if (device.isDefault) {
        selectedId = device.id;
        break;
      }
    }
    selectedId ??= previous.selectedDeviceId;
    return AudioEndpointSnapshot(
      availability: AvailabilityState.enabled,
      devices: effectiveDevices,
      selectedDeviceId: selectedId,
      volume: parsed.volume.clamp(0, 1.5).toDouble(),
      muted: parsed.muted,
    );
  }

  Future<void> setWifi(bool enabled) async {
    await runner.run('nmcli', <String>['radio', 'wifi', enabled ? 'on' : 'off']);
  }

  Future<void> setBluetooth(bool enabled) async {
    await runner.run('bluetoothctl', <String>['power', enabled ? 'on' : 'off']);
  }

  Future<void> setOutputVolume(double value, {String? deviceId}) {
    return _setAudioVolume(
      deviceId ?? '@DEFAULT_AUDIO_SINK@',
      value,
    );
  }

  Future<void> setInputVolume(double value, {String? deviceId}) {
    return _setAudioVolume(
      deviceId ?? '@DEFAULT_AUDIO_SOURCE@',
      value,
    );
  }

  Future<void> setVolume(double value) => setOutputVolume(value);

  Future<void> _setAudioVolume(String target, double value) async {
    _validateAudioTarget(target);
    final double clamped = math.max(0, math.min(1.5, value));
    await runner.run(
      'wpctl',
      <String>['set-volume', target, clamped.toStringAsFixed(2)],
    );
    await runner.run('wpctl', <String>['set-mute', target, '0']);
  }

  Future<void> toggleOutputMute({String? deviceId}) {
    return _toggleAudioMute(deviceId ?? '@DEFAULT_AUDIO_SINK@');
  }

  Future<void> toggleInputMute({String? deviceId}) {
    return _toggleAudioMute(deviceId ?? '@DEFAULT_AUDIO_SOURCE@');
  }

  Future<void> toggleMute() => toggleOutputMute();

  Future<void> _toggleAudioMute(String target) async {
    _validateAudioTarget(target);
    await runner.run(
      'wpctl',
      <String>['set-mute', target, 'toggle'],
    );
  }

  Future<void> setOutputDevice(String deviceId) {
    return _setDefaultAudioDevice(deviceId);
  }

  Future<void> setInputDevice(String deviceId) {
    return _setDefaultAudioDevice(deviceId);
  }

  Future<void> _setDefaultAudioDevice(String deviceId) async {
    if (deviceId == '@DEFAULT_AUDIO_SINK@' ||
        deviceId == '@DEFAULT_AUDIO_SOURCE@') {
      return;
    }
    _validateAudioTarget(deviceId, allowDefaultAliases: false);
    await runner.run('wpctl', <String>['set-default', deviceId]);
  }

  void _validateAudioTarget(
    String value, {
    bool allowDefaultAliases = true,
  }) {
    const Set<String> aliases = <String>{
      '@DEFAULT_AUDIO_SINK@',
      '@DEFAULT_AUDIO_SOURCE@',
    };
    if ((allowDefaultAliases && aliases.contains(value)) ||
        RegExp(r'^\d+$').hasMatch(value)) {
      return;
    }
    throw ArgumentError.value(value, 'value', 'Invalid WirePlumber node id');
  }

  Future<void> setBrightness(double value) async {
    final int percent = (value.clamp(0.01, 1) * 100).round();
    await runner.run('brightnessctl', <String>['set', '$percent%']);
  }

  Future<void> setPowerProfile(String profile) async {
    const Set<String> allowed = <String>{
      'power-saver',
      'balanced',
      'performance',
    };
    if (!allowed.contains(profile)) {
      throw ArgumentError.value(profile, 'profile', 'Unsupported power profile');
    }
    await runner.run('powerprofilesctl', <String>['set', profile]);
  }

  Future<String> screenshot({bool region = true}) async {
    final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final String home = Platform.environment['HOME'] ?? '/tmp';
    final String directory = '$home/Pictures/Screenshots';
    await runner.run('mkdir', <String>['-p', directory]);
    final String output = '$directory/Screenshot-$timestamp.png';
    if (region) {
      final ProcessResultValue selection = await runner.run(
        'slurp',
        const <String>[],
        check: false,
      );
      if (!selection.succeeded || selection.stdout.trim().isEmpty) {
        throw const ProcessFailure('Screenshot selection was cancelled');
      }
      await runner.run(
        'grim',
        <String>['-g', selection.stdout.trim(), output],
      );
    } else {
      await runner.run('grim', <String>[output]);
    }
    return output;
  }

  Future<void> lock() => runner.run('loginctl', <String>['lock-session']);
  Future<void> suspend() => runner.run('systemctl', <String>['suspend']);
  Future<void> hibernate() => runner.run('systemctl', <String>['hibernate']);
  Future<void> reboot() => runner.run('systemctl', <String>['reboot']);
  Future<void> powerOff() => runner.run('systemctl', <String>['poweroff']);

  Future<void> logOut() async {
    if (await runner.exists('uwsm')) {
      await runner.run('uwsm', <String>['stop']);
      return;
    }
    await runner.run('hyprctl', <String>['dispatch', 'exit']);
  }
}
