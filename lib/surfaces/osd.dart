import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../widgets/surface_frame.dart';

class OsdSurface extends StatelessWidget {
  const OsdSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  Widget build(BuildContext context) {
    final double volume = controller.snapshot.volume.clamp(0, 1).toDouble();
    return Center(
      child: SurfaceFrame(
        maxWidth: 420,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(
              controller.snapshot.muted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Volume', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: volume,
                    semanticsLabel: 'Volume',
                    semanticsValue: '${(volume * 100).round()}%',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Text('${(volume * 100).round()}'),
          ],
        ),
      ),
    );
  }
}
