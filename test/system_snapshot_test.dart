import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/core/models/system_snapshot.dart';

void main() {
  test('system snapshot round trips through JSON', () {
    const SystemSnapshot original = SystemSnapshot(
      workspace: 'Web',
      activeApplication: 'Firefox',
      wifi: AvailabilityState.enabled,
      bluetooth: AvailabilityState.disabled,
      outputAudio: AudioEndpointSnapshot(
        availability: AvailabilityState.enabled,
        selectedDeviceId: '51',
        volume: 0.8,
        devices: <AudioDevice>[
          AudioDevice(id: '51', name: 'Built-in speakers', isDefault: true),
          AudioDevice(id: '78', name: 'Headphones'),
        ],
      ),
      inputAudio: AudioEndpointSnapshot(
        availability: AvailabilityState.enabled,
        selectedDeviceId: '52',
        volume: 0.65,
        muted: true,
        devices: <AudioDevice>[
          AudioDevice(id: '52', name: 'Built-in microphone', isDefault: true),
        ],
      ),
      batteryPercent: 62,
      onBattery: true,
      doNotDisturb: true,
      themeSeedArgb: 0xFF123456,
      themeMode: 'system',
      reducedMotion: true,
      wallpaperPath: '/tmp/wallpaper.png',
    );

    final SystemSnapshot decoded = SystemSnapshot.fromJson(original.toJson());
    expect(decoded.workspace, 'Web');
    expect(decoded.activeApplication, 'Firefox');
    expect(decoded.wifi, AvailabilityState.enabled);
    expect(decoded.bluetooth, AvailabilityState.disabled);
    expect(decoded.outputAudio.selectedDevice?.name, 'Built-in speakers');
    expect(decoded.volume, 0.8);
    expect(decoded.inputAudio.selectedDevice?.name, 'Built-in microphone');
    expect(decoded.inputVolume, 0.65);
    expect(decoded.microphoneMuted, isTrue);
    expect(decoded.batteryPercent, 62);
    expect(decoded.onBattery, isTrue);
    expect(decoded.doNotDisturb, isTrue);
    expect(decoded.themeSeedArgb, 0xFF123456);
    expect(decoded.themeMode, 'system');
    expect(decoded.reducedMotion, isTrue);
    expect(decoded.wallpaperPath, '/tmp/wallpaper.png');
  });

  test('explicit audio selection wins over stale default metadata', () {
    const AudioEndpointSnapshot endpoint = AudioEndpointSnapshot(
      selectedDeviceId: '78',
      devices: <AudioDevice>[
        AudioDevice(id: '51', name: 'Speakers', isDefault: true),
        AudioDevice(id: '78', name: 'Headphones'),
      ],
    );
    expect(endpoint.selectedDevice?.name, 'Headphones');
  });

  test('legacy scalar audio fields still decode', () {
    final SystemSnapshot decoded = SystemSnapshot.fromJson(
      <String, Object?>{
        'volume': 0.4,
        'muted': true,
        'inputVolume': 0.6,
        'microphoneMuted': true,
      },
    );
    expect(decoded.outputAudio.volume, 0.4);
    expect(decoded.outputAudio.muted, isTrue);
    expect(decoded.inputAudio.volume, 0.6);
    expect(decoded.inputAudio.muted, isTrue);
  });

  test('unknown enum input degrades to unknown', () {
    final SystemSnapshot decoded = SystemSnapshot.fromJson(
      <String, Object?>{'wifi': 'future-state'},
    );
    expect(decoded.wifi, AvailabilityState.unknown);
  });
}
