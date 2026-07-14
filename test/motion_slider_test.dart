import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/core/theme/motion_theme.dart';
import 'package:motion_shell/widgets/motion_slider.dart';

void main() {
  testWidgets('uses the current expressive default slider anatomy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MotionTheme.create(
          seed: Colors.indigo,
          brightness: Brightness.light,
          reduceMotion: false,
        ),
        home: Scaffold(
          body: MotionSlider(
            value: 0.5,
            onChanged: (_) {},
            semanticLabel: 'Output volume',
            label: '50%',
          ),
        ),
      ),
    );

    final Slider slider = tester.widget<Slider>(find.byType(Slider));
    final BuildContext context = tester.element(find.byType(Slider));
    final SliderThemeData theme = SliderTheme.of(context);

    expect(slider.value, 0.5);
    expect(theme.trackHeight, 16);
    expect(theme.trackGap, 6);
    expect(theme.trackShape, isA<GappedSliderTrackShape>());
    expect(theme.thumbShape, isA<HandleThumbShape>());
  });
}
