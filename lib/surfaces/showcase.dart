import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../core/motion/motion_transitions.dart';
import 'launcher.dart';
import 'notifications.dart';
import 'osd.dart';
import 'overview.dart';
import 'quick_settings.dart';
import 'search.dart';
import 'settings.dart';
import 'system_bar.dart';

class ShowcaseSurface extends StatefulWidget {
  const ShowcaseSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  State<ShowcaseSurface> createState() => _ShowcaseSurfaceState();
}

class _ShowcaseSurfaceState extends State<ShowcaseSurface> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> surfaces = <Widget>[
      QuickSettingsSurface(controller: widget.controller),
      const LauncherSurface(),
      NotificationsSurface(controller: widget.controller),
      OverviewSurface(controller: widget.controller),
      const SearchSurface(),
      OsdSurface(controller: widget.controller),
      SettingsSurface(controller: widget.controller),
    ];
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.tertiaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              SystemBarSurface(
                controller: widget.controller,
                onOpenLauncher: () => setState(() => _selected = 1),
                onOpenQuickSettings: () => setState(() => _selected = 0),
                onOpenNotifications: () => setState(() => _selected = 2),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
                      child: NavigationRail(
                        selectedIndex: _selected,
                        groupAlignment: -1,
                        labelType: NavigationRailLabelType.all,
                        destinations: const <NavigationRailDestination>[
                          NavigationRailDestination(
                            icon: Icon(Icons.tune_rounded),
                            label: Text('Controls'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.apps_rounded),
                            label: Text('Launcher'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.notifications_rounded),
                            label: Text('Alerts'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.space_dashboard_rounded),
                            label: Text('Spaces'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search_rounded),
                            label: Text('Search'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.volume_up_rounded),
                            label: Text('OSD'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.settings_rounded),
                            label: Text('Settings'),
                          ),
                        ],
                        onDestinationSelected: (int value) =>
                            setState(() => _selected = value),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: MotionTransitions.medium,
                            child: SizedBox.expand(
                              key: ValueKey<int>(_selected),
                              child: Center(child: surfaces[_selected]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
