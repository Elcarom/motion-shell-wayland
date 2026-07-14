import 'package:flutter/material.dart';
import 'package:icon_button_m3e/icon_button_m3e.dart';

enum MotionIconButtonVariant { standard, filled, tonal, outlined }

enum MotionIconButtonSize { small, medium }

/// Replaceable boundary for expressive icon buttons used by shell surfaces.
class MotionIconButton extends StatelessWidget {
  const MotionIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
    this.selectedIcon,
    this.isSelected,
    this.variant = MotionIconButtonVariant.standard,
    this.size = MotionIconButtonSize.small,
    this.badgeValue,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool? isSelected;
  final MotionIconButtonVariant variant;
  final MotionIconButtonSize size;
  final Object? badgeValue;

  @override
  Widget build(BuildContext context) {
    return IconButtonM3E(
      icon: icon,
      selectedIcon: selectedIcon,
      onPressed: onPressed,
      tooltip: tooltip,
      semanticLabel: tooltip,
      isSelected: isSelected,
      badgeValue: badgeValue,
      variant: switch (variant) {
        MotionIconButtonVariant.standard => IconButtonM3EVariant.standard,
        MotionIconButtonVariant.filled => IconButtonM3EVariant.filled,
        MotionIconButtonVariant.tonal => IconButtonM3EVariant.tonal,
        MotionIconButtonVariant.outlined => IconButtonM3EVariant.outlined,
      },
      size: switch (size) {
        MotionIconButtonSize.small => IconButtonM3ESize.sm,
        MotionIconButtonSize.medium => IconButtonM3ESize.md,
      },
    );
  }
}
