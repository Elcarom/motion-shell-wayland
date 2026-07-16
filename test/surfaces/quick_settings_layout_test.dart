import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:motion_shell/surfaces/quick_settings.dart';

void main() {
  testWidgets('power profile group fits the quick-settings content width', (
    WidgetTester tester,
  ) async {
    const double contentWidth = 380;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: contentWidth,
              child: buildPowerProfileGroupForTest(
                selectedProfile: 'balanced',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final Finder bounds = find.byKey(
      const ValueKey<String>('power-profile-group-bounds'),
    );
    expect(bounds, findsOneWidget);
    expect(tester.getSize(bounds), const Size(contentWidth, 56));
  });
}
