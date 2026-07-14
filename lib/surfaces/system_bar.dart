import 'dart:async';

import 'package:flutter/material.dart';

import '../app/motion_controller.dart';
import '../core/models/system_snapshot.dart';
import '../core/theme/motion_theme.dart';
import '../widgets/motion_buttons.dart';

class SystemBarSurface extends StatelessWidget {
  const SystemBarSurface({
    required this.controller,
    super.key,
    this.onOpenLauncher,
    this.onOpenQuickSettings,
    this.onOpenNotifications,
  });

  final MotionController controller;
  final VoidCallback? onOpenLauncher;
  final VoidCallback? onOpenQuickSettings;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final SystemSnapshot state = controller.snapshot;
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: colors.surfaceContainer,
        elevation: 2,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: MotionTokens.barHeight,
          child: Row(
            children: <Widget>[
              _WorkspaceButton(
                workspace: state.workspace,
                onPressed: onOpenLauncher,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ActiveApplication(
                  title: state.activeApplication,
                  screenRecording: state.screenRecording,
                ),
              ),
              _ClockButton(onPressed: onOpenNotifications),
              const SizedBox(width: 4),
              _StatusCluster(state: state, onPressed: onOpenQuickSettings),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceButton extends StatelessWidget {
  const _WorkspaceButton({required this.workspace, this.onPressed});

  final String workspace;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: MotionActionButton(
        onPressed: onPressed,
        icon: Icons.apps_rounded,
        label: 'Space $workspace',
      ),
    );
  }
}

class _ActiveApplication extends StatelessWidget {
  const _ActiveApplication({
    required this.title,
    required this.screenRecording,
  });

  final String title;
  final bool screenRecording;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        if (screenRecording) ...<Widget>[
          const SizedBox(width: 10),
          const Icon(Icons.fiber_manual_record_rounded, size: 14),
          const SizedBox(width: 4),
          Text('Sharing', style: Theme.of(context).textTheme.labelMedium),
        ],
      ],
    );
  }
}

class _ClockButton extends StatefulWidget {
  const _ClockButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<_ClockButton> createState() => _ClockButtonState();
}

class _ClockButtonState extends State<_ClockButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final TimeOfDay time = TimeOfDay.fromDateTime(now);
    return MotionActionButton(
      variant: MotionButtonVariant.text,
      onPressed: widget.onPressed,
      label: '${time.format(context)}  ·  ${_weekday(now.weekday)} ${now.day}',
    );
  }

  String _weekday(int weekday) => const <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ][weekday - 1];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _StatusCluster extends StatelessWidget {
  const _StatusCluster({required this.state, this.onPressed});

  final SystemSnapshot state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: MotionActionButton(
        onPressed: onPressed,
        semanticLabel: 'Open control center',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              state.wifi == AvailabilityState.enabled
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Icon(
              state.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              size: 20,
            ),
            if (state.batteryPercent != null) ...<Widget>[
              const SizedBox(width: 8),
              const Icon(Icons.battery_5_bar_rounded, size: 20),
              const SizedBox(width: 2),
              Text('${state.batteryPercent}%'),
            ],
            if (state.unreadNotifications > 0) ...<Widget>[
              const SizedBox(width: 8),
              Badge.count(count: state.unreadNotifications),
            ],
          ],
        ),
      ),
    );
  }
}
