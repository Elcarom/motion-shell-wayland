import 'dart:async';

import 'package:flutter/material.dart';

import 'app/motion_app.dart';
import 'app/motion_controller.dart';
import 'surfaces/surface_kind.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final SurfaceKind surface = SurfaceKind.fromArgs(args);
  final MotionController controller = MotionController();

  final String? wallpaper = args
      .where((String arg) => arg.startsWith('--wallpaper='))
      .map((String arg) => arg.substring('--wallpaper='.length))
      .firstOrNull;

  runApp(MotionApp(controller: controller, surface: surface));

  unawaited(() async {
    await controller.initialize(wallpaperPath: wallpaper);
    if (wallpaper != null) {
      await controller.setWallpaper(wallpaper);
    }
  }());
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
