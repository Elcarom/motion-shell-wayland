import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../core/theme/motion_theme.dart';
import '../widgets/motion_buttons.dart';
import '../widgets/motion_icon_button.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_frame.dart';

class NotificationsSurface extends StatefulWidget {
  const NotificationsSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  State<NotificationsSurface> createState() => _NotificationsSurfaceState();
}

class _NotificationsSurfaceState extends State<NotificationsSurface> {
  final List<_NotificationItem> _items = <_NotificationItem>[
    const _NotificationItem(
      id: 1,
      app: 'Firefox',
      title: 'Download complete',
      body: 'motion-shell-reference.pdf is ready to open.',
      icon: Icons.download_done_rounded,
      urgency: _Urgency.normal,
    ),
    const _NotificationItem(
      id: 2,
      app: 'System',
      title: 'Power profile changed',
      body: 'Balanced mode is active.',
      icon: Icons.balance_rounded,
      urgency: _Urgency.low,
    ),
    const _NotificationItem(
      id: 3,
      app: 'Messages',
      title: 'Alex',
      body: 'The prototype review is moved to 15:30.',
      icon: Icons.chat_bubble_rounded,
      urgency: _Urgency.normal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SurfaceFrame(
      maxWidth: 520,
      child: Column(
        children: <Widget>[
          SectionHeader(
            title: 'Notifications',
            subtitle: widget.controller.snapshot.doNotDisturb
                ? 'Do Not Disturb is active'
                : '${_items.length} recent',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MotionIconButton(
                  tooltip: 'Toggle Do Not Disturb',
                  isSelected: widget.controller.snapshot.doNotDisturb,
                  onPressed: () => widget.controller.setDoNotDisturb(
                    !widget.controller.snapshot.doNotDisturb,
                  ),
                  icon: const Icon(Icons.notifications_active_rounded),
                  selectedIcon: const Icon(Icons.notifications_off_rounded),
                ),
                MotionActionButton(
                  variant: MotionButtonVariant.text,
                  onPressed: _items.isEmpty
                      ? null
                      : () => setState(_items.clear),
                  label: 'Clear all',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _items.isEmpty
                ? const _NotificationEmptyState()
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final _NotificationItem item = _items[index];
                      return Dismissible(
                        key: ValueKey<int>(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => setState(() => _items.remove(item)),
                        background: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(
                              MotionTokens.radiusLarge,
                            ),
                          ),
                          child: const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 24),
                              child: Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                        ),
                        child: _NotificationCard(
                          item: item,
                          onDismiss: () => setState(() => _items.remove(item)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onDismiss});

  final _NotificationItem item;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card.filled(
      color: item.urgency == _Urgency.critical
          ? colors.errorContainer
          : colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Icon(item.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.app,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(item.body),
                    ],
                  ),
                ),
                MotionIconButton(
                  tooltip: 'Dismiss',
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MotionActionButton(
                  variant: MotionButtonVariant.text,
                  onPressed: () {},
                  label: 'Open',
                ),
                const SizedBox(width: 4),
                MotionActionButton(onPressed: () {}, label: 'Action'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.notifications_none_rounded, size: 52),
          const SizedBox(height: 12),
          Text('All clear', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('New notifications will appear here.'),
        ],
      ),
    );
  }
}

enum _Urgency { low, normal, critical }

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.app,
    required this.title,
    required this.body,
    required this.icon,
    required this.urgency,
  });

  final int id;
  final String app;
  final String title;
  final String body;
  final IconData icon;
  final _Urgency urgency;
}
