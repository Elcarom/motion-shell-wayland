import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/integrations/audio/wpctl_parser.dart';

void main() {
  test('parses output and input devices and default selections', () {
    const String status = '''
PipeWire 'pipewire-0'
 └─ Clients:
Audio
 ├─ Devices:
 │      42. Built-in Audio
 ├─ Sinks:
 │  *   51. Built-in Audio Analog Stereo  [vol: 0.54]
 │      78. WH-1000XM5                 [vol: 0.42]
 ├─ Sources:
 │  *   52. Built-in Audio Analog Stereo  [vol: 0.72]
 │      79. WH-1000XM5 Headset Microphone [vol: 1.00]
 │      80. Monitor of Built-in Audio      [vol: 0.50]
 └─ Streams:
''';

    final WpctlAudioCatalog catalog = WpctlParser.parseStatus(status);
    expect(catalog.outputs, hasLength(2));
    expect(catalog.outputs.first.id, '51');
    expect(catalog.outputs.first.isDefault, isTrue);
    expect(catalog.inputs, hasLength(2));
    expect(catalog.inputs.first.id, '52');
    expect(catalog.inputs.first.isDefault, isTrue);
  });

  test('parses volume and mute state', () {
    final ({double volume, bool muted}) value = WpctlParser.parseVolume(
      'Volume: 0.37 [MUTED]',
      fallback: 0.5,
    );
    expect(value.volume, 0.37);
    expect(value.muted, isTrue);
  });

  test('uses fallback for malformed volume output', () {
    final ({double volume, bool muted}) value = WpctlParser.parseVolume(
      'not available',
      fallback: 0.64,
    );
    expect(value.volume, 0.64);
    expect(value.muted, isFalse);
  });
}
