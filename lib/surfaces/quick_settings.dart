import 'package:flutter/material.dart';
import '../app/motion_controller.dart';
import '../core/models/system_snapshot.dart';
import '../widgets/motion_buttons.dart';
import '../widgets/motion_icon_button.dart';
import '../widgets/motion_slider.dart';
import '../widgets/quick_setting_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_frame.dart';

class QuickSettingsSurface extends StatelessWidget {
  const QuickSettingsSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  Widget build(BuildContext context) {
    final SystemSnapshot state = controller.snapshot;
    return SurfaceFrame(
      maxWidth: 560,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SectionHeader(
              title: 'Control center',
              subtitle: controller.serviceConnected
                  ? 'Live system controls'
                  : 'Local fallback mode',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MotionIconButton(
                    tooltip: 'Settings',
                    onPressed: () {},
                    icon: const Icon(Icons.settings_rounded),
                  ),
                  MotionIconButton(
                    tooltip: 'Power and session',
                    onPressed: () => _showSessionSheet(context),
                    icon: const Icon(Icons.power_settings_new_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.25,
              children: <Widget>[
                QuickSettingTile(
                  icon: Icons.wifi_rounded,
                  label: 'Wi‑Fi',
                  subtitle: _stateLabel(state.wifi, enabled: 'Connected'),
                  state: state.wifi,
                  onChanged: controller.setWifi,
                ),
                QuickSettingTile(
                  icon: Icons.bluetooth_rounded,
                  label: 'Bluetooth',
                  subtitle: _stateLabel(state.bluetooth, enabled: 'Available'),
                  state: state.bluetooth,
                  onChanged: controller.setBluetooth,
                ),
                QuickSettingTile(
                  icon: Icons.do_not_disturb_on_rounded,
                  label: 'Do Not Disturb',
                  subtitle: state.doNotDisturb
                      ? 'Silencing alerts'
                      : 'Alerts on',
                  state: state.doNotDisturb
                      ? AvailabilityState.enabled
                      : AvailabilityState.disabled,
                  onChanged: controller.setDoNotDisturb,
                ),
                QuickSettingTile(
                  icon: Icons.dark_mode_rounded,
                  label: 'Dark theme',
                  subtitle: controller.themeMode == ThemeMode.dark
                      ? 'On'
                      : 'Off',
                  state: controller.themeMode == ThemeMode.dark
                      ? AvailabilityState.enabled
                      : AvailabilityState.disabled,
                  onChanged: (bool enabled) => controller.setThemeMode(
                    enabled ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
                const QuickSettingTile(
                  icon: Icons.nightlight_round,
                  label: 'Night light',
                  subtitle: 'Unavailable in prototype',
                  state: AvailabilityState.unavailable,
                  onChanged: null,
                ),
                QuickSettingTile(
                  icon: Icons.keyboard_rounded,
                  label: 'Keyboard',
                  subtitle: 'English (US)',
                  state: AvailabilityState.disabled,
                  onChanged: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Audio', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _AudioControl(
              title: 'Output',
              endpoint: state.outputAudio,
              mutedIcon: Icons.volume_off_rounded,
              activeIcon: Icons.volume_up_rounded,
              sliderEndIcon: Icons.volume_up_rounded,
              onDeviceSelected: controller.setOutputDevice,
              onVolumeChanged: controller.setOutputVolume,
              onMuteToggle: controller.toggleOutputMute,
              emphasis: MotionSliderEmphasis.primary,
            ),
            const SizedBox(height: 10),
            _AudioControl(
              title: 'Input',
              endpoint: state.inputAudio,
              mutedIcon: Icons.mic_off_rounded,
              activeIcon: Icons.mic_rounded,
              sliderEndIcon: Icons.mic_rounded,
              onDeviceSelected: controller.setInputDevice,
              onVolumeChanged: controller.setInputVolume,
              onMuteToggle: controller.toggleInputMute,
              emphasis: MotionSliderEmphasis.secondary,
            ),
            const SizedBox(height: 10),
            _ExpressiveValueControl(
              icon: Icons.brightness_6_rounded,
              title: 'Brightness',
              value: state.brightness,
              onChanged: controller.setBrightness,
            ),
            const SizedBox(height: 18),
            Text(
              'Power profile',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 10),
            _PowerProfileGroup(
              selectedProfile: state.powerProfile,
              onChanged: controller.setPowerProfile,
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: MotionActionButton(
                    size: MotionButtonSize.medium,
                    onPressed: controller.takeScreenshot,
                    icon: Icons.screenshot_rounded,
                    label: 'Screenshot',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MotionActionButton(
                    size: MotionButtonSize.medium,
                    onPressed: null,
                    icon: Icons.videocam_rounded,
                    label: 'Record',
                  ),
                ),
              ],
            ),
            if (controller.lastError != null) ...<Widget>[
              const SizedBox(height: 14),
              Card.filled(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.error_outline_rounded),
                  title: const Text('A system control failed'),
                  subtitle: Text(controller.lastError!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _stateLabel(AvailabilityState state, {required String enabled}) {
    return switch (state) {
      AvailabilityState.enabled => enabled,
      AvailabilityState.disabled => 'Off',
      AvailabilityState.unavailable => 'Not available',
      AvailabilityState.loading => 'Updating…',
      AvailabilityState.error => 'Needs attention',
      AvailabilityState.unknown => 'Checking…',
    };
  }

  Future<void> _showSessionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _SessionAction(
              icon: Icons.lock_rounded,
              label: 'Lock',
              onPressed: () => controller.sessionAction('lock'),
            ),
            _SessionAction(
              icon: Icons.bedtime_rounded,
              label: 'Suspend',
              onPressed: () => controller.sessionAction('suspend'),
            ),
            _SessionAction(
              icon: Icons.logout_rounded,
              label: 'Log out',
              onPressed: () => controller.sessionAction('logout'),
            ),
            _SessionAction(
              icon: Icons.restart_alt_rounded,
              label: 'Restart',
              onPressed: () => controller.sessionAction('reboot'),
            ),
            _SessionAction(
              icon: Icons.power_settings_new_rounded,
              label: 'Shut down',
              onPressed: () => controller.sessionAction('poweroff'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioControl extends StatelessWidget {
  const _AudioControl({
    required this.title,
    required this.endpoint,
    required this.mutedIcon,
    required this.activeIcon,
    required this.sliderEndIcon,
    required this.onDeviceSelected,
    required this.onVolumeChanged,
    required this.onMuteToggle,
    required this.emphasis,
  });

  final String title;
  final AudioEndpointSnapshot endpoint;
  final IconData mutedIcon;
  final IconData activeIcon;
  final IconData sliderEndIcon;
  final ValueChanged<String> onDeviceSelected;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggle;
  final MotionSliderEmphasis emphasis;

  @override
  Widget build(BuildContext context) {
    final AudioDevice? selected = endpoint.selectedDevice;
    final bool enabled =
        endpoint.availability == AvailabilityState.enabled &&
        endpoint.devices.isNotEmpty;
    final String deviceLabel = selected?.name ?? 'No $title device';

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  endpoint.muted
                      ? 'Muted'
                      : '${(endpoint.volume * 100).round()}%',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: MotionSplitButton<String>(
                label: deviceLabel,
                leadingIcon: endpoint.muted ? mutedIcon : activeIcon,
                leadingTooltip: endpoint.muted
                    ? 'Unmute $title'
                    : 'Mute $title',
                trailingTooltip: 'Select $title device',
                enabled: enabled,
                selectedValue: endpoint.selectedDeviceId,
                items: endpoint.devices
                    .map(
                      (AudioDevice device) => MotionMenuItem<String>(
                        value: device.id,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              device.id == endpoint.selectedDeviceId
                                  ? Icons.check_rounded
                                  : title == 'Output'
                                  ? Icons.speaker_rounded
                                  : Icons.mic_rounded,
                            ),
                            const SizedBox(width: 10),
                            Flexible(child: Text(device.name)),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
                onSelected: onDeviceSelected,
                onPressed: onMuteToggle,
              ),
            ),
            const SizedBox(height: 10),
            MotionSlider(
              value: endpoint.volume,
              max: 1.5,
              label: '${(endpoint.volume * 100).round()}%',
              semanticLabel: '$title volume',
              emphasis: emphasis,
              startIcon: Icon(endpoint.muted ? mutedIcon : activeIcon),
              endIcon: Icon(sliderEndIcon),
              onChanged: enabled ? onVolumeChanged : null,
            ),
            if (!enabled) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'The ${title.toLowerCase()} endpoint is unavailable or needs attention.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpressiveValueControl extends StatelessWidget {
  const _ExpressiveValueControl({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text('${(value * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            MotionSlider(
              value: value,
              label: '${(value * 100).round()}%',
              semanticLabel: title,
              emphasis: MotionSliderEmphasis.secondary,
              startIcon: Icon(icon),
              endIcon: const Icon(Icons.brightness_high_rounded),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerProfileGroup extends StatelessWidget {
  const _PowerProfileGroup({
    required this.selectedProfile,
    required this.onChanged,
  });

  final String selectedProfile;
  final ValueChanged<String> onChanged;

  static const List<MotionChoice<String>> _profiles = <MotionChoice<String>>[
    MotionChoice<String>(
      value: 'power-saver',
      icon: Icons.eco_rounded,
      label: 'Saver',
      semanticLabel: 'Power saver',
    ),
    MotionChoice<String>(
      value: 'balanced',
      icon: Icons.balance_rounded,
      label: 'Balanced',
      semanticLabel: 'Balanced',
    ),
    MotionChoice<String>(
      value: 'performance',
      icon: Icons.speed_rounded,
      label: 'Fast',
      semanticLabel: 'Performance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MotionChoiceGroup<String>(
      choices: _profiles,
      selected: selectedProfile,
      onChanged: onChanged,
      semanticLabel: 'Power profile',
      size: MotionButtonSize.medium,
    );
  }
}

class _SessionAction extends StatelessWidget {
  const _SessionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MotionActionButton(
      size: MotionButtonSize.medium,
      onPressed: onPressed,
      icon: icon,
      label: label,
    );
  }
}
