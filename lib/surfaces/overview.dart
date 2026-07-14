import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../core/theme/motion_theme.dart';
import '../integrations/hyprland/hyprland_client.dart';
import '../widgets/motion_buttons.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_frame.dart';

class OverviewSurface extends StatelessWidget {
  const OverviewSurface({
    required this.controller,
    super.key,
    this.hyprland = const HyprlandClient(),
  });

  final MotionController controller;
  final HyprlandClient hyprland;

  @override
  Widget build(BuildContext context) {
    return SurfaceFrame(
      maxWidth: 1200,
      child: Column(
        children: <Widget>[
          SectionHeader(
            title: 'Spaces',
            subtitle: 'A spatial map of work, not a miniature desktop clone',
            trailing: MotionActionButton(
              onPressed: () {},
              icon: Icons.add_rounded,
              label: 'New space',
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                NavigationRail(
                  selectedIndex: 0,
                  labelType: NavigationRailLabelType.all,
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.space_dashboard_outlined),
                      selectedIcon: Icon(Icons.space_dashboard_rounded),
                      label: Text('Spaces'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.window_outlined),
                      selectedIcon: Icon(Icons.window_rounded),
                      label: Text('Windows'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search_rounded),
                      label: Text('Find'),
                    ),
                  ],
                  onDestinationSelected: (_) {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth > 800 ? 3 : 2;
                      return GridView.builder(
                        itemCount: 6,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.5,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final int workspace = index + 1;
                          return _WorkspaceCard(
                            workspace: workspace,
                            active: controller.snapshot.workspace == '$workspace',
                            windows: index == 0
                                ? const <_WindowPreview>[
                                    _WindowPreview('Firefox', Icons.public_rounded),
                                    _WindowPreview('Editor', Icons.code_rounded),
                                  ]
                                : index == 1
                                    ? const <_WindowPreview>[
                                        _WindowPreview('Files', Icons.folder_rounded),
                                      ]
                                    : const <_WindowPreview>[],
                            onActivate: () => hyprland.dispatch('workspace', '$workspace'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.workspace,
    required this.active,
    required this.windows,
    required this.onActivate,
  });

  final int workspace;
  final bool active;
  final List<_WindowPreview> windows;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card.filled(
      color: active ? colors.primaryContainer : colors.surfaceContainerHighest,
      child: InkWell(
        onTap: onActivate,
        borderRadius: BorderRadius.circular(MotionTokens.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Space $workspace', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (active)
                    const Icon(Icons.radio_button_checked_rounded)
                  else
                    const Icon(Icons.radio_button_unchecked_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: windows.isEmpty
                    ? Center(
                        child: Text(
                          'Room to begin',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      )
                    : Row(
                        children: windows
                            .map(
                              (_WindowPreview window) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(MotionTokens.radiusMedium),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(window.icon, size: 34),
                                          const SizedBox(height: 8),
                                          Text(window.title),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowPreview {
  const _WindowPreview(this.title, this.icon);

  final String title;
  final IconData icon;
}
