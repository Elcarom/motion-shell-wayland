import 'dart:async';

import 'package:flutter/material.dart';

import '../core/motion/motion_transitions.dart';
import '../core/theme/motion_theme.dart';
import '../integrations/apps/application_catalog.dart';
import '../widgets/motion_buttons.dart';
import '../widgets/motion_icon_button.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_frame.dart';

class LauncherSurface extends StatefulWidget {
  const LauncherSurface({super.key, ApplicationCatalog? catalog})
    : catalog = catalog ?? const ApplicationCatalog();

  final ApplicationCatalog catalog;

  @override
  State<LauncherSurface> createState() => _LauncherSurfaceState();
}

class _LauncherSurfaceState extends State<LauncherSurface> {
  final SearchController _searchController = SearchController();
  List<DesktopApplication> _applications = _fallbackApps;
  String _query = '';
  bool _loading = true;
  bool _gridMode = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final List<DesktopApplication> discovered = await widget.catalog.discover();
    if (!mounted) {
      return;
    }
    setState(() {
      _applications = discovered.isEmpty ? _fallbackApps : discovered;
      _loading = false;
    });
  }

  List<DesktopApplication> get _filtered {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _applications;
    }
    return _applications
        .where((DesktopApplication app) {
          return app.name.toLowerCase().contains(query) ||
              (app.comment ?? '').toLowerCase().contains(query) ||
              app.categories.any(
                (String value) => value.toLowerCase().contains(query),
              );
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<DesktopApplication> results = _filtered;
    return SurfaceFrame(
      maxWidth: 1120,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SearchBar(
                  controller: _searchController,
                  autofocus: true,
                  hintText: 'Search apps, settings, files, and actions',
                  leading: const Icon(Icons.search_rounded),
                  trailing: <Widget>[
                    if (_query.isNotEmpty)
                      MotionIconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                  ],
                  onChanged: (String value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(width: 12),
              const MotionIconButton(
                tooltip: 'Voice search unavailable',
                onPressed: null,
                variant: MotionIconButtonVariant.tonal,
                icon: Icon(Icons.mic_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: _query.isEmpty ? 'Your apps' : 'Results',
            subtitle: _loading
                ? 'Discovering installed applications…'
                : '${results.length} available',
            trailing: MotionChoiceGroup<bool>(
              choices: const <MotionChoice<bool>>[
                MotionChoice<bool>(
                  value: true,
                  icon: Icons.grid_view_rounded,
                  semanticLabel: 'Grid view',
                ),
                MotionChoice<bool>(
                  value: false,
                  icon: Icons.view_list_rounded,
                  semanticLabel: 'List view',
                ),
              ],
              selected: _gridMode,
              onChanged: (bool value) => setState(() => _gridMode = value),
              semanticLabel: 'Application layout',
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: MotionTransitions.medium,
              child: results.isEmpty
                  ? const _EmptyLauncherState()
                  : LayoutBuilder(
                      key: ValueKey<String>(_query),
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            if (!_gridMode) {
                              return ListView.separated(
                                itemCount: results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 6),
                                itemBuilder: (BuildContext context, int index) {
                                  final DesktopApplication app = results[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        app.name.characters.first.toUpperCase(),
                                      ),
                                    ),
                                    title: Text(app.name),
                                    subtitle: Text(
                                      app.comment ?? 'Application',
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_rounded,
                                    ),
                                    onTap: () => widget.catalog.launch(app),
                                  );
                                },
                              );
                            }
                            final int columns = switch (constraints.maxWidth) {
                              < 640 => 4,
                              < 900 => 6,
                              _ => 8,
                            };
                            return GridView.builder(
                              itemCount: results.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.92,
                                  ),
                              itemBuilder: (BuildContext context, int index) {
                                final DesktopApplication app = results[index];
                                return _ApplicationTile(
                                  app: app,
                                  onPressed: () => widget.catalog.launch(app),
                                );
                              },
                            );
                          },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.app, required this.onPressed});

  final DesktopApplication app;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: app.comment ?? app.name,
      child: Card.filled(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(MotionTokens.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.tertiaryContainer,
                  foregroundColor: colors.onTertiaryContainer,
                  child: Text(
                    app.name.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  app.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLauncherState extends StatelessWidget {
  const _EmptyLauncherState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.search_off_rounded, size: 48),
          const SizedBox(height: 12),
          Text('No matches', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Try an application name, setting, or action.'),
        ],
      ),
    );
  }
}

const List<DesktopApplication> _fallbackApps = <DesktopApplication>[
  DesktopApplication(id: 'firefox', name: 'Firefox', exec: 'firefox'),
  DesktopApplication(
    id: 'org.wezfurlong.wezterm',
    name: 'WezTerm',
    exec: 'wezterm',
  ),
  DesktopApplication(id: 'org.gnome.Nautilus', name: 'Files', exec: 'nautilus'),
  DesktopApplication(
    id: 'org.gnome.TextEditor',
    name: 'Text Editor',
    exec: 'gnome-text-editor',
  ),
  DesktopApplication(
    id: 'org.gnome.Calculator',
    name: 'Calculator',
    exec: 'gnome-calculator',
  ),
  DesktopApplication(
    id: 'org.gnome.Loupe',
    name: 'Image Viewer',
    exec: 'loupe',
  ),
  DesktopApplication(
    id: 'io.github.celluloid_player.Celluloid',
    name: 'Videos',
    exec: 'celluloid',
  ),
  DesktopApplication(
    id: 'motion-settings',
    name: 'Settings',
    exec: 'motion-shell --surface=settings',
  ),
];
