import 'availability_state.dart';

class AudioDevice {
  const AudioDevice({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  factory AudioDevice.fromJson(Map<String, Object?> json) {
    return AudioDevice(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown audio device',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final bool isDefault;

  AudioDevice copyWith({bool? isDefault}) {
    return AudioDevice(
      id: id,
      name: name,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'isDefault': isDefault,
  };
}

class AudioEndpointSnapshot {
  const AudioEndpointSnapshot({
    this.availability = AvailabilityState.unknown,
    this.devices = const <AudioDevice>[],
    this.selectedDeviceId,
    this.volume = 0.5,
    this.muted = false,
  });

  factory AudioEndpointSnapshot.fromJson(Map<String, Object?> json) {
    final Object? devicesValue = json['devices'];
    final List<AudioDevice> devices = devicesValue is List
        ? devicesValue
              .whereType<Map>()
              .map(
                (Map<dynamic, dynamic> item) =>
                    AudioDevice.fromJson(Map<String, Object?>.from(item)),
              )
              .toList(growable: false)
        : const <AudioDevice>[];
    return AudioEndpointSnapshot(
      availability: AvailabilityState.fromName(json['availability'] as String?),
      devices: devices,
      selectedDeviceId: json['selectedDeviceId'] as String?,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.5,
      muted: json['muted'] as bool? ?? false,
    );
  }

  final AvailabilityState availability;
  final List<AudioDevice> devices;
  final String? selectedDeviceId;
  final double volume;
  final bool muted;

  bool get isAvailable => availability != AvailabilityState.unavailable;

  AudioDevice? get selectedDevice {
    if (selectedDeviceId case final String selectedId) {
      for (final AudioDevice device in devices) {
        if (device.id == selectedId) {
          return device;
        }
      }
    }
    for (final AudioDevice device in devices) {
      if (device.isDefault) {
        return device;
      }
    }
    return devices.isEmpty ? null : devices.first;
  }

  AudioEndpointSnapshot copyWith({
    AvailabilityState? availability,
    List<AudioDevice>? devices,
    String? selectedDeviceId,
    bool clearSelectedDeviceId = false,
    double? volume,
    bool? muted,
  }) {
    return AudioEndpointSnapshot(
      availability: availability ?? this.availability,
      devices: devices ?? this.devices,
      selectedDeviceId: clearSelectedDeviceId
          ? null
          : selectedDeviceId ?? this.selectedDeviceId,
      volume: volume ?? this.volume,
      muted: muted ?? this.muted,
    );
  }

  AudioEndpointSnapshot selecting(String deviceId) {
    return copyWith(
      selectedDeviceId: deviceId,
      devices: devices
          .map(
            (AudioDevice device) =>
                device.copyWith(isDefault: device.id == deviceId),
          )
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'availability': availability.name,
    'devices': devices.map((AudioDevice item) => item.toJson()).toList(),
    'selectedDeviceId': selectedDeviceId,
    'volume': volume,
    'muted': muted,
  };
}
