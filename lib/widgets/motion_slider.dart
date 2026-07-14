import 'package:flutter/material.dart';

enum MotionSliderEmphasis { primary, secondary, neutral }

/// Desktop adaptation of the current Material 3 Expressive slider anatomy.
///
/// Flutter does not yet expose the complete M3E slider API, so Motion keeps the
/// official [Slider] interaction, semantics, focus, keyboard behavior, gapped
/// track, and handle while applying the current expressive 16 dp track and
/// 6 dp handle gap. The wrapper is replaceable when Flutter exposes the full
/// XS–XL size scale, inset-track icons, and native vertical orientation.
class MotionSlider extends StatelessWidget {
  const MotionSlider({
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
    this.min = 0,
    this.max = 1,
    this.label,
    this.startIcon,
    this.endIcon,
    this.emphasis = MotionSliderEmphasis.primary,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final String semanticLabel;
  final double min;
  final double max;
  final String? label;
  final Widget? startIcon;
  final Widget? endIcon;
  final MotionSliderEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color activeColor = switch (emphasis) {
      MotionSliderEmphasis.primary => colors.primary,
      MotionSliderEmphasis.secondary => colors.secondary,
      MotionSliderEmphasis.neutral => colors.onSurface,
    };
    final Color disabledActive = activeColor.withValues(alpha: 0.38);
    final Color inactiveColor = colors.surfaceContainerHighest;
    final Color disabledInactive = colors.onSurface.withValues(alpha: 0.12);

    final Widget slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackShape: const GappedSliderTrackShape(),
        thumbShape: const HandleThumbShape(),
        trackHeight: 16,
        trackGap: 6,
        thumbSize: WidgetStateProperty.resolveWith<Size?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return const Size(2, 44);
          }

          return const Size(4, 44);
        }),
        activeTrackColor: activeColor,
        inactiveTrackColor: inactiveColor,
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.12),
        disabledActiveTrackColor: disabledActive,
        disabledInactiveTrackColor: disabledInactive,
        disabledThumbColor: disabledActive,
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      child: Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        label: label,
        semanticFormatterCallback: (_) => label ?? semanticLabel,
        onChanged: onChanged,
      ),
    );

    return Row(
      children: <Widget>[
        if (startIcon != null) ...<Widget>[
          IconTheme(
            data: IconThemeData(
              color: onChanged == null ? disabledActive : activeColor,
              size: 22,
            ),
            child: startIcon!,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(child: slider),
        if (endIcon != null) ...<Widget>[
          const SizedBox(width: 4),
          IconTheme(
            data: IconThemeData(
              color: onChanged == null
                  ? colors.onSurface.withValues(alpha: 0.38)
                  : colors.onSurfaceVariant,
              size: 22,
            ),
            child: endIcon!,
          ),
        ],
      ],
    );
  }
}
