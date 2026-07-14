import 'package:flutter/material.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

enum MotionButtonVariant { filled, tonal, elevated, outlined, text }

enum MotionButtonSize { small, medium }

class MotionActionButton extends StatelessWidget {
  const MotionActionButton({
    required this.onPressed,
    super.key,
    this.label,
    this.icon,
    this.child,
    this.tooltip,
    this.semanticLabel,
    this.variant = MotionButtonVariant.tonal,
    this.size = MotionButtonSize.small,
  }) : assert(label != null || child != null);

  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final Widget? child;
  final String? tooltip;
  final String? semanticLabel;
  final MotionButtonVariant variant;
  final MotionButtonSize size;

  @override
  Widget build(BuildContext context) {
    final Widget content =
        child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[Icon(icon), const SizedBox(width: 8)],
            Flexible(child: Text(label!)),
          ],
        );
    return M3EButton(
      style: switch (variant) {
        MotionButtonVariant.filled => M3EButtonStyle.filled,
        MotionButtonVariant.tonal => M3EButtonStyle.tonal,
        MotionButtonVariant.elevated => M3EButtonStyle.elevated,
        MotionButtonVariant.outlined => M3EButtonStyle.outlined,
        MotionButtonVariant.text => M3EButtonStyle.text,
      },
      size: switch (size) {
        MotionButtonSize.small => M3EButtonSize.sm,
        MotionButtonSize.medium => M3EButtonSize.md,
      },
      tooltip: tooltip,
      semanticLabel: semanticLabel ?? label,
      onPressed: onPressed,
      child: content,
    );
  }
}

class MotionChoice<T> {
  const MotionChoice({
    required this.value,
    required this.semanticLabel,
    this.icon,
    this.label,
    this.enabled = true,
  });

  final T value;
  final String semanticLabel;
  final IconData? icon;
  final String? label;
  final bool enabled;
}

class MotionChoiceGroup<T> extends StatelessWidget {
  const MotionChoiceGroup({
    required this.choices,
    required this.selected,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
    this.size = MotionButtonSize.small,
  });

  final List<MotionChoice<T>> choices;
  final T? selected;
  final ValueChanged<T> onChanged;
  final String semanticLabel;
  final MotionButtonSize size;

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = choices.indexWhere(
      (MotionChoice<T> choice) => choice.value == selected,
    );
    return M3EToggleButtonGroup(
      type: M3EButtonGroupType.connected,
      style: M3EButtonStyle.tonal,
      size: switch (size) {
        MotionButtonSize.small => M3EButtonSize.sm,
        MotionButtonSize.medium => M3EButtonSize.md,
      },
      selectedIndex: selectedIndex < 0 ? null : selectedIndex,
      semanticLabel: semanticLabel,
      actions: choices
          .map(
            (MotionChoice<T> choice) => M3EToggleButtonGroupAction(
              icon: choice.icon == null ? null : Icon(choice.icon),
              label: choice.label == null ? null : Text(choice.label!),
              semanticLabel: choice.semanticLabel,
              enabled: choice.enabled,
            ),
          )
          .toList(growable: false),
      onSelectedIndexChanged: (int? index) {
        if (index != null) {
          onChanged(choices[index].value);
        }
      },
    );
  }
}

class MotionMenuItem<T> {
  const MotionMenuItem({required this.value, required this.child});

  final T value;
  final Widget child;
}

class MotionSplitButton<T> extends StatelessWidget {
  const MotionSplitButton({
    required this.label,
    required this.leadingIcon,
    required this.items,
    required this.onSelected,
    required this.onPressed,
    required this.leadingTooltip,
    required this.trailingTooltip,
    super.key,
    this.selectedValue,
    this.enabled = true,
  });

  final String label;
  final IconData leadingIcon;
  final List<MotionMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final VoidCallback? onPressed;
  final String leadingTooltip;
  final String trailingTooltip;
  final T? selectedValue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return M3ESplitButton<T>(
      style: M3EButtonStyle.tonal,
      size: M3EButtonSize.md,
      label: label,
      leadingIcon: leadingIcon,
      leadingTooltip: leadingTooltip,
      trailingTooltip: trailingTooltip,
      enabled: enabled,
      selectedValue: selectedValue,
      items: items
          .map(
            (MotionMenuItem<T> item) =>
                M3ESplitButtonItem<T>(value: item.value, child: item.child),
          )
          .toList(growable: false),
      onSelected: onSelected,
      onPressed: onPressed,
    );
  }
}
