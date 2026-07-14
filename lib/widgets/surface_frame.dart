import 'package:flutter/material.dart';

import '../core/theme/motion_theme.dart';

class SurfaceFrame extends StatelessWidget {
  const SurfaceFrame({
    required this.child,
    super.key,
    this.padding = MotionTokens.surfacePadding,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MotionTokens.radiusExtraLarge),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
