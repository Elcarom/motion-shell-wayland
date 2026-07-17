import 'package:flutter/material.dart';

import '../core/theme/motion_theme.dart';
import '../surfaces/launcher.dart';
import '../surfaces/notifications.dart';
import '../surfaces/osd.dart';
import '../surfaces/overview.dart';
import '../surfaces/quick_settings.dart';
import '../surfaces/search.dart';
import '../surfaces/settings.dart';
import '../surfaces/showcase.dart';
import '../surfaces/surface_kind.dart';
import '../surfaces/system_bar.dart';
import 'motion_controller.dart';

class MotionApp extends StatelessWidget {
  const MotionApp({required this.controller, required this.surface, super.key});

  final MotionController controller;
  final SurfaceKind surface;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Motion Shell',
          themeMode: controller.themeMode,
          theme: MotionTheme.create(
            seed: controller.seed,
            brightness: Brightness.light,
            reduceMotion: controller.reduceMotion,
          ),
          darkTheme: MotionTheme.create(
            seed: controller.seed,
            brightness: Brightness.dark,
            reduceMotion: controller.reduceMotion,
          ),
          home: _SurfaceHost(surface: surface, controller: controller),
        );
      },
    );
  }
}

class _SurfaceHost extends StatelessWidget {
  const _SurfaceHost({required this.surface, required this.controller});

  final SurfaceKind surface;
  final MotionController controller;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (surface) {
      SurfaceKind.showcase => ShowcaseSurface(controller: controller),
      SurfaceKind.bar => SystemBarSurface(controller: controller),
      SurfaceKind.quickSettings => QuickSettingsSurface(controller: controller),
      SurfaceKind.launcher => const LauncherSurface(),
      SurfaceKind.notifications => NotificationsSurface(controller: controller),
      SurfaceKind.overview => OverviewSurface(controller: controller),
      SurfaceKind.search => const SearchSurface(),
      SurfaceKind.osd => OsdSurface(controller: controller),
      SurfaceKind.settings => SettingsSurface(controller: controller),
    };
    if (surface == SurfaceKind.settings || surface == SurfaceKind.showcase) {
      return child;
    }

    final Widget positionedChild =
        surface == SurfaceKind.quickSettings ||
            surface == SurfaceKind.notifications
        ? Align(alignment: Alignment.topRight, child: child)
        : child;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Padding(
          padding: surface == SurfaceKind.bar
              ? EdgeInsets.zero
              : surface == SurfaceKind.quickSettings ||
                    surface == SurfaceKind.notifications
              ? const EdgeInsets.fromLTRB(8, 8, 0, 8)
              : const EdgeInsets.all(8),
          child: positionedChild,
        ),
      ),
    );
  }
}
