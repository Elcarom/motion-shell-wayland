import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/core/models/system_snapshot.dart';
import 'package:motion_shell/core/theme/motion_theme.dart';
import 'package:motion_shell/widgets/quick_setting_tile.dart';

void main() {
  testWidgets('quick setting exposes toggle semantics and changes value', (
    WidgetTester tester,
  ) async {
    bool? nextValue;
    await tester.pumpWidget(
      MaterialApp(
        theme: MotionTheme.create(
          seed: const Color(0xFF6750A4),
          brightness: Brightness.light,
          reduceMotion: false,
        ),
        home: Scaffold(
          body: QuickSettingTile(
            icon: Icons.wifi_rounded,
            label: 'Wi-Fi',
            subtitle: 'Connected',
            state: AvailabilityState.enabled,
            onChanged: (bool value) => nextValue = value,
          ),
        ),
      ),
    );

    expect(find.text('Wi-Fi'), findsOneWidget);
    await tester.tap(find.byType(QuickSettingTile));
    await tester.pump();
    expect(nextValue, isFalse);
  });

  testWidgets('unavailable quick setting does not activate', (
    WidgetTester tester,
  ) async {
    bool called = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: MotionTheme.create(
          seed: const Color(0xFF6750A4),
          brightness: Brightness.dark,
          reduceMotion: false,
        ),
        home: Scaffold(
          body: QuickSettingTile(
            icon: Icons.nightlight_round,
            label: 'Night light',
            subtitle: 'Unavailable',
            state: AvailabilityState.unavailable,
            onChanged: (_) => called = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(QuickSettingTile));
    expect(called, isFalse);
  });
}
