import 'package:flutter/material.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

import '../core/models/system_snapshot.dart';

/// Desktop adaptation of an M3 Expressive toggle button.
///
/// The two-line label and service-state icon are shell-specific, while shape,
/// hover, press, focus, selected-state motion, and disabled behavior come from
/// the expressive button implementation.
class QuickSettingTile extends StatelessWidget {
  const QuickSettingTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.state,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final AvailabilityState state;
  final ValueChanged<bool>? onChanged;

  bool get _selected => state == AvailabilityState.enabled;
  bool get _enabled =>
      state != AvailabilityState.unavailable &&
      state != AvailabilityState.loading;

  @override
  Widget build(BuildContext context) {
    final Widget stateIcon = switch (state) {
      AvailabilityState.loading => const LoadingIndicatorM3E(
          constraints: BoxConstraints.tightFor(width: 28, height: 28),
          semanticLabel: 'Updating quick setting',
        ),
      AvailabilityState.error => const Icon(Icons.error_outline_rounded),
      _ => Icon(icon),
    };
    final Widget text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 240;
        final double height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 76;
        return M3EToggleButton(
          checked: _selected,
          enabled: _enabled && onChanged != null,
          style: M3EButtonStyle.tonal,
          size: M3EButtonSize.custom(
            width: width,
            height: height,
            hPadding: 16,
            iconSize: 24,
            iconGap: 12,
          ),
          icon: stateIcon,
          checkedIcon: stateIcon,
          label: text,
          checkedLabel: text,
          semanticLabel: '$label, $subtitle',
          onCheckedChange: (bool value) => onChanged?.call(value),
        );
      },
    );
  }
}
