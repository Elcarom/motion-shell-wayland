import 'dart:async';

import 'package:flutter/material.dart';

import 'app/motion_app.dart';
import 'app/motion_controller.dart';
import 'core/platform/layer_surface_host.dart';
import 'surfaces/surface_kind.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final SurfaceKind surface = SurfaceKind.fromArgs(args);
  try {
    await WaylandLayerSurfaceHost().configure(surface).timeout(
          const Duration(seconds: 2),
        );
  } on Object {
    // A regular Flutter window is the deliberate development/recovery fallback.
  }
  final MotionController controller = MotionController();
  final String? wallpaper = args
      .where((String arg) => arg.startsWith('--wallpaper='))
      .map((String arg) => arg.substring('--wallpaper='.length))
      .firstOrNull;
  await controller.initialize(wallpaperPath: wallpaper);
  if (wallpaper != null) {
    await controller.setWallpaper(wallpaper);
  }
  runApp(MotionApp(controller: controller, surface: surface));
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
