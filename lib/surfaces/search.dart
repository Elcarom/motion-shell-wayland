import 'package:flutter/material.dart';

import '../widgets/surface_frame.dart';

class SearchSurface extends StatefulWidget {
  const SearchSurface({super.key});

  @override
  State<SearchSurface> createState() => _SearchSurfaceState();
}

class _SearchSurfaceState extends State<SearchSurface> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final List<_SearchResult> results = _query.trim().isEmpty
        ? _suggestions
        : _suggestions
              .where(
                (_SearchResult item) => '${item.title} ${item.subtitle}'
                    .toLowerCase()
                    .contains(_query.toLowerCase()),
              )
              .toList(growable: false);
    return Center(
      child: SurfaceFrame(
        maxWidth: 760,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SearchBar(
              autoFocus: true,
              hintText: 'Search Motion',
              leading: const Icon(Icons.search_rounded),
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 460),
              child: results.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48),
                      child: Text('No local results yet.'),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (BuildContext context, int index) {
                        final _SearchResult item = results[index];
                        return ListTile(
                          leading: Icon(item.icon),
                          title: Text(item.title),
                          subtitle: Text(item.subtitle),
                          trailing: const Icon(Icons.arrow_forward_rounded),
                          onTap: () {},
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

const List<_SearchResult> _suggestions = <_SearchResult>[
  _SearchResult(Icons.public_rounded, 'Firefox', 'Application'),
  _SearchResult(Icons.window_rounded, 'Project notes — Editor', 'Open window'),
  _SearchResult(Icons.settings_rounded, 'Appearance', 'Settings'),
  _SearchResult(Icons.calculate_rounded, '42 × 18 = 756', 'Calculator'),
  _SearchResult(Icons.folder_rounded, 'Downloads', 'Folder'),
  _SearchResult(
    Icons.power_settings_new_rounded,
    'Lock screen',
    'System action',
  ),
];
