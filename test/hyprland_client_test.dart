import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/integrations/hyprland/hyprland_client.dart';

void main() {
  group('HyprlandEvent.parse', () {
    test('parses a valid event', () {
      final HyprlandEvent event = HyprlandEvent.parse('workspacev2>>2,Web');
      expect(event.name, 'workspacev2');
      expect(event.data, '2,Web');
    });

    test('preserves malformed input safely', () {
      final HyprlandEvent event = HyprlandEvent.parse('not-an-event');
      expect(event.name, 'malformed');
      expect(event.data, 'not-an-event');
    });

    test('does not split data after the first separator', () {
      final HyprlandEvent event = HyprlandEvent.parse(
        'activewindow>>firefox,Title >> with marker',
      );
      expect(event.name, 'activewindow');
      expect(event.data, 'firefox,Title >> with marker');
    });
  });
}
