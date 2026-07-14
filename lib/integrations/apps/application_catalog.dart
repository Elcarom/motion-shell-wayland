import 'dart:io';

import '../../core/platform/process_runner.dart';

class DesktopApplication {
  const DesktopApplication({
    required this.id,
    required this.name,
    required this.exec,
    this.icon,
    this.comment,
    this.categories = const <String>[],
  });

  final String id;
  final String name;
  final String exec;
  final String? icon;
  final String? comment;
  final List<String> categories;
}

class ApplicationCatalog {
  const ApplicationCatalog({this.runner = const SafeProcessRunner()});

  final SafeProcessRunner runner;

  Future<List<DesktopApplication>> discover() async {
    final Set<String> seen = <String>{};
    final List<DesktopApplication> applications = <DesktopApplication>[];
    for (final String directory in _directories()) {
      final Directory dir = Directory(directory);
      if (!await dir.exists()) {
        continue;
      }
      await for (final FileSystemEntity entity in dir.list(followLinks: false)) {
        if (entity is! File || !entity.path.endsWith('.desktop')) {
          continue;
        }
        final DesktopApplication? app = await _parse(entity);
        if (app != null && seen.add(app.id)) {
          applications.add(app);
        }
      }
    }
    applications.sort(
      (DesktopApplication a, DesktopApplication b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return applications;
  }

  Future<void> launch(DesktopApplication app) async {
    final bool hasUwsm = await runner.exists('uwsm');
    if (hasUwsm) {
      await runner.run('uwsm', <String>['app', '--', 'gtk-launch', app.id]);
    } else {
      await runner.run('gtk-launch', <String>[app.id]);
    }
  }

  List<String> _directories() {
    final String home = Platform.environment['HOME'] ?? '';
    final String dataHome = Platform.environment['XDG_DATA_HOME'] ??
        (home.isEmpty ? '' : '$home/.local/share');
    final String dataDirs = Platform.environment['XDG_DATA_DIRS'] ??
        '/usr/local/share:/usr/share';
    return <String>[
      if (dataHome.isNotEmpty) '$dataHome/applications',
      ...dataDirs.split(':').map((String value) => '$value/applications'),
    ];
  }

  Future<DesktopApplication?> _parse(File file) async {
    try {
      final List<String> lines = await file.readAsLines();
      bool inDesktopEntry = false;
      final Map<String, String> fields = <String, String>{};
      for (final String rawLine in lines) {
        final String line = rawLine.trim();
        if (line == '[Desktop Entry]') {
          inDesktopEntry = true;
          continue;
        }
        if (line.startsWith('[') && inDesktopEntry) {
          break;
        }
        if (!inDesktopEntry || line.isEmpty || line.startsWith('#')) {
          continue;
        }
        final int equals = line.indexOf('=');
        if (equals <= 0) {
          continue;
        }
        fields.putIfAbsent(
          line.substring(0, equals),
          () => line.substring(equals + 1),
        );
      }
      if (fields['Type'] != 'Application' ||
          fields['NoDisplay'] == 'true' ||
          fields['Hidden'] == 'true' ||
          fields['Name'] == null ||
          fields['Exec'] == null) {
        return null;
      }
      final String id = file.uri.pathSegments.last.replaceFirst('.desktop', '');
      return DesktopApplication(
        id: id,
        name: fields['Name']!,
        exec: fields['Exec']!,
        icon: fields['Icon'],
        comment: fields['Comment'],
        categories: (fields['Categories'] ?? '')
            .split(';')
            .where((String value) => value.isNotEmpty)
            .toList(growable: false),
      );
    } on Object {
      return null;
    }
  }
}
