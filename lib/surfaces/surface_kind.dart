enum SurfaceKind {
  showcase,
  bar,
  quickSettings,
  launcher,
  notifications,
  overview,
  search,
  osd,
  settings;

  static SurfaceKind fromArgs(List<String> args) {
    final String? value = args
        .where((String value) => value.startsWith('--surface='))
        .map((String value) => value.substring('--surface='.length))
        .firstOrNull;
    return switch (value) {
      'bar' => SurfaceKind.bar,
      'quick-settings' => SurfaceKind.quickSettings,
      'launcher' => SurfaceKind.launcher,
      'notifications' => SurfaceKind.notifications,
      'overview' => SurfaceKind.overview,
      'search' => SurfaceKind.search,
      'osd' => SurfaceKind.osd,
      'settings' => SurfaceKind.settings,
      _ => SurfaceKind.showcase,
    };
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
