import 'dart:convert';

import 'audio_device.dart';
import 'availability_state.dart';

export 'availability_state.dart';
export 'audio_device.dart';

class SystemSnapshot {
  const SystemSnapshot({
    this.workspace = '1',
    this.activeApplication = 'Desktop',
    this.wifi = AvailabilityState.unknown,
    this.bluetooth = AvailabilityState.unknown,
    AudioEndpointSnapshot? outputAudio,
    AudioEndpointSnapshot? inputAudio,
    double volume = 0.56,
    bool muted = false,
    double inputVolume = 0.72,
    bool microphoneMuted = false,
    this.brightness = 0.72,
    this.batteryPercent,
    this.onBattery = false,
    this.powerProfile = 'balanced',
    this.doNotDisturb = false,
    this.unreadNotifications = 2,
    this.screenRecording = false,
    this.themeSeedArgb = 0xFF6750A4,
    this.themeMode = 'dark',
    this.reducedMotion = false,
    this.wallpaperPath,
  })  : outputAudio = outputAudio ??
            AudioEndpointSnapshot(
              volume: volume,
              muted: muted,
            ),
        inputAudio = inputAudio ??
            AudioEndpointSnapshot(
              volume: inputVolume,
              muted: microphoneMuted,
            );

  factory SystemSnapshot.fromJson(Map<String, Object?> json) {
    final Object? outputValue = json['outputAudio'];
    final Object? inputValue = json['inputAudio'];
    return SystemSnapshot(
      workspace: json['workspace'] as String? ?? '1',
      activeApplication: json['activeApplication'] as String? ?? 'Desktop',
      wifi: AvailabilityState.fromName(json['wifi'] as String?),
      bluetooth: AvailabilityState.fromName(json['bluetooth'] as String?),
      outputAudio: outputValue is Map
          ? AudioEndpointSnapshot.fromJson(
              Map<String, Object?>.from(outputValue),
            )
          : null,
      inputAudio: inputValue is Map
          ? AudioEndpointSnapshot.fromJson(
              Map<String, Object?>.from(inputValue),
            )
          : null,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.56,
      muted: json['muted'] as bool? ?? false,
      inputVolume: (json['inputVolume'] as num?)?.toDouble() ?? 0.72,
      microphoneMuted: json['microphoneMuted'] as bool? ?? false,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.72,
      batteryPercent: (json['batteryPercent'] as num?)?.toInt(),
      onBattery: json['onBattery'] as bool? ?? false,
      powerProfile: json['powerProfile'] as String? ?? 'balanced',
      doNotDisturb: json['doNotDisturb'] as bool? ?? false,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      screenRecording: json['screenRecording'] as bool? ?? false,
      themeSeedArgb:
          (json['themeSeedArgb'] as num?)?.toInt() ?? 0xFF6750A4,
      themeMode: json['themeMode'] as String? ?? 'dark',
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      wallpaperPath: json['wallpaperPath'] as String?,
    );
  }

  final String workspace;
  final String activeApplication;
  final AvailabilityState wifi;
  final AvailabilityState bluetooth;
  final AudioEndpointSnapshot outputAudio;
  final AudioEndpointSnapshot inputAudio;
  final double brightness;
  final int? batteryPercent;
  final bool onBattery;
  final String powerProfile;
  final bool doNotDisturb;
  final int unreadNotifications;
  final bool screenRecording;
  final int themeSeedArgb;
  final String themeMode;
  final bool reducedMotion;
  final String? wallpaperPath;

  double get volume => outputAudio.volume;
  bool get muted => outputAudio.muted;
  double get inputVolume => inputAudio.volume;
  bool get microphoneMuted => inputAudio.muted;

  SystemSnapshot copyWith({
    String? workspace,
    String? activeApplication,
    AvailabilityState? wifi,
    AvailabilityState? bluetooth,
    AudioEndpointSnapshot? outputAudio,
    AudioEndpointSnapshot? inputAudio,
    double? volume,
    bool? muted,
    double? inputVolume,
    bool? microphoneMuted,
    double? brightness,
    int? batteryPercent,
    bool clearBatteryPercent = false,
    bool? onBattery,
    String? powerProfile,
    bool? doNotDisturb,
    int? unreadNotifications,
    bool? screenRecording,
    int? themeSeedArgb,
    String? themeMode,
    bool? reducedMotion,
    String? wallpaperPath,
    bool clearWallpaperPath = false,
  }) {
    return SystemSnapshot(
      workspace: workspace ?? this.workspace,
      activeApplication: activeApplication ?? this.activeApplication,
      wifi: wifi ?? this.wifi,
      bluetooth: bluetooth ?? this.bluetooth,
      outputAudio: outputAudio ??
          this.outputAudio.copyWith(
            volume: volume,
            muted: muted,
          ),
      inputAudio: inputAudio ??
          this.inputAudio.copyWith(
            volume: inputVolume,
            muted: microphoneMuted,
          ),
      brightness: brightness ?? this.brightness,
      batteryPercent:
          clearBatteryPercent ? null : batteryPercent ?? this.batteryPercent,
      onBattery: onBattery ?? this.onBattery,
      powerProfile: powerProfile ?? this.powerProfile,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      screenRecording: screenRecording ?? this.screenRecording,
      themeSeedArgb: themeSeedArgb ?? this.themeSeedArgb,
      themeMode: themeMode ?? this.themeMode,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      wallpaperPath:
          clearWallpaperPath ? null : wallpaperPath ?? this.wallpaperPath,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'workspace': workspace,
        'activeApplication': activeApplication,
        'wifi': wifi.name,
        'bluetooth': bluetooth.name,
        'outputAudio': outputAudio.toJson(),
        'inputAudio': inputAudio.toJson(),
        // Legacy scalar fields keep older surfaces and state snapshots readable.
        'volume': volume,
        'muted': muted,
        'inputVolume': inputVolume,
        'microphoneMuted': microphoneMuted,
        'brightness': brightness,
        'batteryPercent': batteryPercent,
        'onBattery': onBattery,
        'powerProfile': powerProfile,
        'doNotDisturb': doNotDisturb,
        'unreadNotifications': unreadNotifications,
        'screenRecording': screenRecording,
        'themeSeedArgb': themeSeedArgb,
        'themeMode': themeMode,
        'reducedMotion': reducedMotion,
        'wallpaperPath': wallpaperPath,
      };

  String encode() => jsonEncode(toJson());
}
