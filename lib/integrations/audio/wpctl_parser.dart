import '../../core/models/audio_device.dart';

class WpctlAudioCatalog {
  const WpctlAudioCatalog({
    this.outputs = const <AudioDevice>[],
    this.inputs = const <AudioDevice>[],
  });

  final List<AudioDevice> outputs;
  final List<AudioDevice> inputs;
}

class WpctlParser {
  const WpctlParser._();

  static WpctlAudioCatalog parseStatus(String value) {
    final List<AudioDevice> outputs = <AudioDevice>[];
    final List<AudioDevice> inputs = <AudioDevice>[];
    _AudioSection section = _AudioSection.none;

    for (final String rawLine in value.split('\n')) {
      final String line = rawLine.trimRight();
      if (line.contains('Sinks:')) {
        section = _AudioSection.outputs;
        continue;
      }
      if (line.contains('Sources:')) {
        section = _AudioSection.inputs;
        continue;
      }
      if (RegExp(r'^\s*[├└]─\s+[^\s].*:$').hasMatch(line) &&
          !line.contains('Sinks:') &&
          !line.contains('Sources:')) {
        section = _AudioSection.none;
        continue;
      }
      if (section == _AudioSection.none) {
        continue;
      }

      final RegExpMatch? match = RegExp(
        r'^\s*[│\s]*([*])?\s*(\d+)\.\s+(.+?)\s*(?:\[vol:.*)?$',
      ).firstMatch(line);
      if (match == null) {
        continue;
      }
      final String id = match.group(2)!;
      final String name = _cleanName(match.group(3)!);
      if (name.isEmpty ||
          (section == _AudioSection.inputs &&
              name.toLowerCase().contains('monitor of '))) {
        continue;
      }
      final AudioDevice device = AudioDevice(
        id: id,
        name: name,
        isDefault: match.group(1) == '*',
      );
      if (section == _AudioSection.outputs) {
        outputs.add(device);
      } else {
        inputs.add(device);
      }
    }

    return WpctlAudioCatalog(
      outputs: List<AudioDevice>.unmodifiable(outputs),
      inputs: List<AudioDevice>.unmodifiable(inputs),
    );
  }

  static ({double volume, bool muted}) parseVolume(
    String value, {
    required double fallback,
  }) {
    final RegExpMatch? match = RegExp(
      r'Volume:\s*([0-9]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(value);
    return (
      volume: double.tryParse(match?.group(1) ?? '') ?? fallback,
      muted: value.contains('[MUTED]'),
    );
  }

  static String _cleanName(String value) {
    return value
        .replaceFirst(RegExp(r'\s+\[vol:.*$'), '')
        .replaceFirst(RegExp(r'\s+\[[^\]]+\]\s*$'), '')
        .trim();
  }
}

enum _AudioSection { none, outputs, inputs }
