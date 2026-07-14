import 'package:flutter/material.dart';
import 'package:m3e_design/m3e_design.dart';

import '../motion/motion_transitions.dart';

abstract final class MotionTokens {
  static const double touchTarget = 48;
  static const double compactTouchTarget = 40;
  static const double radiusSmall = 12;
  static const double radiusMedium = 20;
  static const double radiusLarge = 28;
  static const double radiusExtraLarge = 36;
  static const double barHeight = 56;

  static const EdgeInsets surfacePadding = EdgeInsets.all(20);
  static const EdgeInsets controlPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
}

class MotionTheme {
  const MotionTheme._();

  static ThemeData create({
    required Color seed,
    required Brightness brightness,
    required bool reduceMotion,
  }) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final TextTheme textTheme =
        ThemeData(useMaterial3: true, colorScheme: scheme).textTheme.apply(
          fontFamily: 'Roboto',
          displayColor: scheme.onSurface,
          bodyColor: scheme.onSurface,
        );

    final Duration animationDuration = MotionTransitions.resolve(
      MotionTransitions.short,
      reduceMotion: reduceMotion,
    );
    final RoundedRectangleBorder mediumShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MotionTokens.radiusMedium),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[M3ETheme.defaults(scheme)],
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MotionTokens.radiusLarge),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MotionTokens.radiusExtraLarge),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          animationDuration: animationDuration,
          minimumSize: const Size(
            MotionTokens.touchTarget,
            MotionTokens.touchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          animationDuration: animationDuration,
          minimumSize: const Size(
            MotionTokens.touchTarget,
            MotionTokens.touchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(MotionTokens.touchTarget),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll<double>(0),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MotionTokens.radiusExtraLarge),
          ),
        ),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
      sliderTheme: const SliderThemeData(
        trackShape: GappedSliderTrackShape(),
        thumbShape: HandleThumbShape(),
        trackGap: 6,
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearMinHeight: 10,
        borderRadius: BorderRadius.all(Radius.circular(999)),
        trackGap: 4,
        stopIndicatorRadius: 2,
      ),
      switchTheme: SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MotionTokens.radiusSmall),
        ),
        side: BorderSide.none,
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: 56,
        shape: mediumShape,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      tooltipTheme: const TooltipThemeData(
        waitDuration: Duration(milliseconds: 550),
      ),
      focusColor: scheme.secondaryContainer.withValues(alpha: 0.55),
    );
  }
}
