import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../core/motion/motion_transitions.dart';
import '../widgets/motion_buttons.dart';
import '../widgets/motion_icon_button.dart';
import '../widgets/section_header.dart';

class SettingsSurface extends StatefulWidget {
  const SettingsSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  State<SettingsSurface> createState() => _SettingsSurfaceState();
}

class _SettingsSurfaceState extends State<SettingsSurface> {
  int _selected = 0;

  static const List<_SettingsDestination> _destinations =
      <_SettingsDestination>[
        _SettingsDestination(
          Icons.palette_outlined,
          Icons.palette_rounded,
          'Appearance',
        ),
        _SettingsDestination(
          Icons.notifications_outlined,
          Icons.notifications_rounded,
          'Notifications',
        ),
        _SettingsDestination(
          Icons.tune_outlined,
          Icons.tune_rounded,
          'Quick settings',
        ),
        _SettingsDestination(
          Icons.volume_up_outlined,
          Icons.volume_up_rounded,
          'Audio',
        ),
        _SettingsDestination(
          Icons.monitor_outlined,
          Icons.monitor_rounded,
          'Displays',
        ),
        _SettingsDestination(
          Icons.keyboard_outlined,
          Icons.keyboard_rounded,
          'Keyboard',
        ),
        _SettingsDestination(
          Icons.space_dashboard_outlined,
          Icons.space_dashboard_rounded,
          'Workspaces',
        ),
        _SettingsDestination(
          Icons.battery_saver_outlined,
          Icons.battery_saver_rounded,
          'Power',
        ),
        _SettingsDestination(
          Icons.accessibility_new_outlined,
          Icons.accessibility_new_rounded,
          'Accessibility',
        ),
        _SettingsDestination(
          Icons.info_outline_rounded,
          Icons.info_rounded,
          'About',
        ),
        _SettingsDestination(
          Icons.monitor_heart_outlined,
          Icons.monitor_heart_rounded,
          'Diagnostics',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= 860;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Motion settings'),
            actions: <Widget>[
              MotionIconButton(
                tooltip: 'Search settings',
                onPressed: () {},
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          body: Row(
            children: <Widget>[
              if (wide)
                NavigationRail(
                  selectedIndex: _selected,
                  extended: constraints.maxWidth >= 1120,
                  labelType: constraints.maxWidth >= 1120
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  groupAlignment: -1,
                  destinations: _destinations
                      .map(
                        (_SettingsDestination item) =>
                            NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            ),
                      )
                      .toList(growable: false),
                  onDestinationSelected: (int value) =>
                      setState(() => _selected = value),
                ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: MotionTransitions.medium,
                  child: _SettingsPage(
                    key: ValueKey<int>(_selected),
                    destination: _destinations[_selected],
                    controller: widget.controller,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selected.clamp(0, 3).toInt(),
                  destinations: _destinations
                      .take(4)
                      .map(
                        (_SettingsDestination item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(growable: false),
                  onDestinationSelected: (int value) =>
                      setState(() => _selected = value),
                ),
        );
      },
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.destination,
    required this.controller,
    super.key,
  });

  final _SettingsDestination destination;
  final MotionController controller;

  Future<void> _chooseWallpaper(BuildContext context) async {
    final TextEditingController pathController = TextEditingController(
      text: controller.snapshot.wallpaperPath ?? '',
    );
    final String? path = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.wallpaper_rounded),
        title: const Text('Use wallpaper'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: pathController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Image path',
              hintText: '/home/user/Pictures/wallpaper.jpg',
              helperText: 'PNG, JPEG, WebP, and other image package formats',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (String value) => Navigator.pop(context, value),
          ),
        ),
        actions: <Widget>[
          MotionActionButton(
            variant: MotionButtonVariant.text,
            onPressed: () => Navigator.pop(context),
            label: 'Cancel',
          ),
          MotionActionButton(
            variant: MotionButtonVariant.filled,
            onPressed: () => Navigator.pop(context, pathController.text),
            label: 'Apply',
          ),
        ],
      ),
    );
    pathController.dispose();
    if (path != null && path.trim().isNotEmpty) {
      await controller.setWallpaper(path.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (destination.label != 'Appearance' &&
        destination.label != 'Accessibility' &&
        destination.label != 'Diagnostics') {
      return _DeferredSettingsPage(destination: destination);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
      children: <Widget>[
        SectionHeader(
          title: destination.label,
          subtitle: switch (destination.label) {
            'Appearance' =>
              'Wallpaper-driven color, theme, and desktop identity',
            'Accessibility' => 'Motion, contrast, scale, and input preferences',
            _ => 'Service health and recovery information',
          },
        ),
        const SizedBox(height: 24),
        if (destination.label == 'Appearance') ...<Widget>[
          _ThemeModeCard(controller: controller),
          const SizedBox(height: 12),
          Card.filled(
            child: ListTile(
              leading: const Icon(Icons.wallpaper_rounded),
              title: const Text('Wallpaper and dynamic color'),
              subtitle: Text(
                controller.snapshot.wallpaperPath ??
                    'Choose an image; the palette updates every shell surface.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _chooseWallpaper(context),
            ),
          ),
          const SizedBox(height: 12),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Current seed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (final double opacity in <double>[
                        1,
                        .82,
                        .64,
                        .46,
                        .28,
                      ])
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: controller.seed.withValues(
                            alpha: opacity,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ] else if (destination.label == 'Accessibility') ...<Widget>[
          Card.filled(
            child: SwitchListTile(
              secondary: const Icon(Icons.motion_photos_off_rounded),
              title: const Text('Reduce motion'),
              subtitle: const Text(
                'Replaces spatial transitions with immediate state changes.',
              ),
              value: controller.reduceMotion,
              onChanged: controller.setReducedMotion,
            ),
          ),
          const SizedBox(height: 12),
          const Card.filled(
            child: ListTile(
              leading: Icon(Icons.contrast_rounded),
              title: Text('Contrast'),
              subtitle: Text('Standard — contrast variants are planned.'),
            ),
          ),
          const SizedBox(height: 12),
          const Card.filled(
            child: ListTile(
              leading: Icon(Icons.keyboard_rounded),
              title: Text('Keyboard navigation'),
              subtitle: Text(
                'Focus traversal, Escape/back behavior, and shortcuts enabled.',
              ),
            ),
          ),
        ] else ...<Widget>[
          _DiagnosticTile(
            icon: controller.serviceConnected
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            title: 'Motion state service',
            status: controller.serviceConnected ? 'Connected' : 'Fallback mode',
          ),
          const SizedBox(height: 10),
          _DiagnosticTile(
            icon: controller.lastError == null
                ? Icons.check_circle_rounded
                : Icons.error_rounded,
            title: 'Last integration error',
            status: controller.lastError ?? 'None',
          ),
          const SizedBox(height: 16),
          MotionActionButton(
            onPressed: controller.refreshLocalSnapshot,
            icon: Icons.refresh_rounded,
            label: 'Refresh diagnostics',
          ),
        ],
      ],
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({required this.controller});

  final MotionController controller;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Color mode', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            MotionChoiceGroup<ThemeMode>(
              choices: const <MotionChoice<ThemeMode>>[
                MotionChoice<ThemeMode>(
                  value: ThemeMode.system,
                  icon: Icons.brightness_auto_rounded,
                  label: 'System',
                  semanticLabel: 'Follow system theme',
                ),
                MotionChoice<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icons.light_mode_rounded,
                  label: 'Light',
                  semanticLabel: 'Light theme',
                ),
                MotionChoice<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark',
                  semanticLabel: 'Dark theme',
                ),
              ],
              selected: controller.themeMode,
              onChanged: controller.setThemeMode,
              semanticLabel: 'Color mode',
              size: MotionButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeferredSettingsPage extends StatelessWidget {
  const _DeferredSettingsPage({required this.destination});

  final _SettingsDestination destination;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card.filled(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(destination.selectedIcon, size: 48),
                const SizedBox(height: 16),
                Text(
                  destination.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This section is represented in the architecture and navigation, but only functional prototype controls are exposed.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiagnosticTile extends StatelessWidget {
  const _DiagnosticTile({
    required this.icon,
    required this.title,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(status),
      ),
    );
  }
}

class _SettingsDestination {
  const _SettingsDestination(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
