import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_buttons/m3e_buttons.dart';

import '../app/motion_controller.dart';
import '../core/models/system_snapshot.dart';
import '../core/platform/command_runner.dart';
import '../widgets/surface_frame.dart';

enum _QuickSettingsPage {
  home,
  network,
  bluetooth,
  theme,
  output,
  input,
  power,
}

class QuickSettingsSurface extends StatefulWidget {
  const QuickSettingsSurface({required this.controller, super.key});

  final MotionController controller;

  @override
  State<QuickSettingsSurface> createState() => _QuickSettingsSurfaceState();
}

class _QuickSettingsSurfaceState extends State<QuickSettingsSurface> {
  static const double _contentHeight = 590;

  _QuickSettingsPage _page = _QuickSettingsPage.home;
  Alignment _transitionOrigin = Alignment.center;

  void _openPage(_QuickSettingsPage page, Alignment origin) {
    setState(() {
      _transitionOrigin = origin;
      _page = page;
    });
  }

  void _closePage() {
    setState(() {
      _page = _QuickSettingsPage.home;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SystemSnapshot state = widget.controller.snapshot;

    return SurfaceFrame(
      maxWidth: 408,
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        height: _contentHeight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          reverseDuration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
                alignment: _transitionOrigin,
                child: child,
              ),
            );
          },
          child: switch (_page) {
            _QuickSettingsPage.home => _QuickSettingsHome(
              key: const ValueKey<String>('quick-settings-home'),
              controller: widget.controller,
              state: state,
              onOpenPage: _openPage,
            ),
            _QuickSettingsPage.network => _NetworkSelectionPage(
              key: const ValueKey<String>('quick-settings-network'),
              initialWifiState: state.wifi,
              onWifiChanged: widget.controller.setWifi,
              onBack: _closePage,
            ),
            _QuickSettingsPage.bluetooth => _BluetoothSelectionPage(
              key: const ValueKey<String>('quick-settings-bluetooth'),
              initialState: state.bluetooth,
              onEnabledChanged: widget.controller.setBluetooth,
              onBack: _closePage,
            ),
            _QuickSettingsPage.theme => _ThemeDetailPage(
              key: const ValueKey<String>('quick-settings-theme'),
              controller: widget.controller,
              onBack: _closePage,
            ),
            _QuickSettingsPage.output => _AudioDeviceDetailPage(
              key: const ValueKey<String>('quick-settings-output'),
              title: 'Audio output',
              endpoint: state.outputAudio,
              icon: Icons.speaker_rounded,
              onSelected: widget.controller.setOutputDevice,
              onBack: _closePage,
            ),
            _QuickSettingsPage.input => _AudioDeviceDetailPage(
              key: const ValueKey<String>('quick-settings-input'),
              title: 'Audio input',
              endpoint: state.inputAudio,
              icon: Icons.mic_rounded,
              onSelected: widget.controller.setInputDevice,
              onBack: _closePage,
            ),
            _QuickSettingsPage.power => _SessionDetailPage(
              key: const ValueKey<String>('quick-settings-power'),
              controller: widget.controller,
              onBack: _closePage,
            ),
          },
        ),
      ),
    );
  }
}

class _QuickSettingsHome extends StatelessWidget {
  const _QuickSettingsHome({
    required this.controller,
    required this.state,
    required this.onOpenPage,
    super.key,
  });

  final MotionController controller;
  final SystemSnapshot state;
  final void Function(_QuickSettingsPage page, Alignment origin) onOpenPage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ShadeSlider(
          semanticLabel: 'Brightness',
          value: state.brightness,
          max: 1,
          activeColor: colors.primary,
          leading: const Icon(Icons.brightness_low_rounded),
          trailing: const Icon(Icons.brightness_high_rounded),
          onChanged: controller.setBrightness,
        ),
        const SizedBox(height: 14),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.35,
          children: <Widget>[
            _NetworkTile(
              wifiState: state.wifi,
              onOpen: () => onOpenPage(
                _QuickSettingsPage.network,
                const Alignment(-0.68, -0.32),
              ),
            ),
            _ShadeTile(
              icon: Icons.bluetooth_rounded,
              title: 'Bluetooth',
              subtitle: _availabilityLabel(state.bluetooth, enabled: 'On'),
              selected: state.bluetooth == AvailabilityState.enabled,
              enabled: state.bluetooth != AvailabilityState.loading,
              showChevron: true,
              onTap: () => onOpenPage(
                _QuickSettingsPage.bluetooth,
                const Alignment(0.68, -0.32),
              ),
            ),
            _ShadeTile(
              icon: Icons.do_not_disturb_on_rounded,
              title: 'Do Not Disturb',
              subtitle: state.doNotDisturb ? 'On' : 'Off',
              selected: state.doNotDisturb,
              onTap: () {
                controller.setDoNotDisturb(!state.doNotDisturb);
              },
            ),
            _ShadeTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark theme',
              subtitle: _themeModeLabel(controller.themeMode),
              selected: Theme.of(context).brightness == Brightness.dark,
              showChevron: true,
              onTap: () => onOpenPage(
                _QuickSettingsPage.theme,
                const Alignment(0.68, -0.04),
              ),
            ),
            const _ShadeTile(
              icon: Icons.keyboard_rounded,
              title: 'Keyboard',
              subtitle: 'English (US)',
              selected: false,
            ),
            const _ShadeTile(
              icon: Icons.nightlight_round,
              title: 'Night light',
              subtitle: 'Unavailable',
              selected: false,
              enabled: false,
            ),
            _ShadeTile(
              icon: state.outputAudio.muted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              title: 'Output',
              subtitle: _audioDeviceLabel(state.outputAudio),
              selected: state.outputAudio.isAvailable,
              enabled: state.outputAudio.isAvailable,
              showChevron: true,
              onTap: () => onOpenPage(
                _QuickSettingsPage.output,
                const Alignment(-0.68, 0.34),
              ),
            ),
            _ShadeTile(
              icon: state.inputAudio.muted
                  ? Icons.mic_off_rounded
                  : Icons.mic_rounded,
              title: 'Input',
              subtitle: _audioDeviceLabel(state.inputAudio),
              selected: state.inputAudio.isAvailable,
              enabled: state.inputAudio.isAvailable,
              showChevron: true,
              onTap: () => onOpenPage(
                _QuickSettingsPage.input,
                const Alignment(0.68, 0.34),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ShadeSlider(
          semanticLabel: 'Master volume',
          value: state.outputAudio.volume,
          max: 1.5,
          activeColor: colors.primary,
          leading: Icon(
            state.outputAudio.muted
                ? Icons.volume_off_rounded
                : Icons.volume_down_rounded,
          ),
          trailing: const Icon(Icons.volume_up_rounded),
          onLeadingPressed: state.outputAudio.isAvailable
              ? controller.toggleOutputMute
              : null,
          onChanged: state.outputAudio.isAvailable
              ? controller.setOutputVolume
              : null,
        ),
        const SizedBox(height: 12),
        _PowerProfileGroup(
          selectedProfile: state.powerProfile,
          onChanged: controller.setPowerProfile,
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (controller.lastError != null) ...<Widget>[
              _RoundUtilityButton(
                tooltip: controller.lastError!,
                icon: Icons.error_outline_rounded,
                onPressed: () =>
                    _showErrorDialog(context, controller.lastError!),
              ),
              const SizedBox(width: 8),
            ],
            _RoundUtilityButton(
              tooltip: 'Settings',
              icon: Icons.settings_rounded,
              onPressed: () => _showSettingsPlaceholder(context),
            ),
            const SizedBox(width: 8),
            _RoundUtilityButton(
              tooltip: 'Power and session',
              icon: Icons.power_settings_new_rounded,
              selected: true,
              onPressed: () =>
                  onOpenPage(_QuickSettingsPage.power, Alignment.bottomRight),
            ),
          ],
        ),
      ],
    );
  }
}

class _NetworkTile extends StatefulWidget {
  const _NetworkTile({required this.wifiState, required this.onOpen});

  final AvailabilityState wifiState;
  final VoidCallback onOpen;

  @override
  State<_NetworkTile> createState() => _NetworkTileState();
}

class _NetworkTileState extends State<_NetworkTile> {
  _NetworkOverview? _overview;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final _NetworkOverview overview = await _readNetworkOverview();
    if (mounted) {
      setState(() => _overview = overview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _NetworkOverview overview =
        _overview ??
        _NetworkOverview(
          icon: widget.wifiState == AvailabilityState.enabled
              ? Icons.wifi_rounded
              : Icons.lan_rounded,
          subtitle: _availabilityLabel(
            widget.wifiState,
            enabled: 'Wi-Fi · Connected',
          ),
          selected: widget.wifiState == AvailabilityState.enabled,
        );

    return _ShadeTile(
      icon: overview.icon,
      title: 'Network',
      subtitle: overview.subtitle,
      selected: overview.selected,
      showChevron: true,
      onTap: widget.onOpen,
    );
  }
}

class _ShadeTile extends StatelessWidget {
  const _ShadeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.enabled = true,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color background = selected
        ? colors.secondaryContainer
        : colors.surfaceContainerHigh;
    final Color foreground = selected
        ? colors.onSecondaryContainer
        : colors.onSurface;
    final Color secondary = selected
        ? colors.onSecondaryContainer.withValues(alpha: 0.76)
        : colors.onSurfaceVariant;
    final double opacity = enabled ? 1 : 0.45;

    return Semantics(
      button: onTap != null,
      enabled: enabled,
      selected: selected,
      label: '$title, $subtitle',
      excludeSemantics: true,
      child: Opacity(
        opacity: opacity,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(21),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 9, 10, 9),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(icon, size: 20, color: foreground),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: secondary,
                            fontSize: 12,
                            height: 1.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showChevron) ...<Widget>[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: foreground,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShadeSlider extends StatelessWidget {
  const _ShadeSlider({
    required this.semanticLabel,
    required this.value,
    required this.max,
    required this.activeColor,
    required this.leading,
    required this.trailing,
    required this.onChanged,
    this.onLeadingPressed,
  });

  final String semanticLabel;
  final double value;
  final double max;
  final Color activeColor;
  final Widget leading;
  final Widget trailing;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onLeadingPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String semanticValue =
        '${((value / max) * 100).clamp(0, 100).round()} percent';

    final Widget slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackShape: const GappedSliderTrackShape(),
        thumbShape: const HandleThumbShape(),
        trackHeight: 8,
        trackGap: 3,
        thumbSize: WidgetStateProperty.resolveWith<Size?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return const Size(2, 30);
          }
          return const Size(3, 30);
        }),
        activeTrackColor: activeColor,
        inactiveTrackColor: colors.surfaceContainerHighest,
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.12),
        disabledActiveTrackColor: activeColor.withValues(alpha: 0.38),
        disabledInactiveTrackColor: colors.onSurface.withValues(alpha: 0.12),
        disabledThumbColor: activeColor.withValues(alpha: 0.38),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: Slider(
        value: value.clamp(0, max).toDouble(),
        max: max,
        semanticFormatterCallback: (_) => semanticValue,
        onChanged: onChanged,
      ),
    );

    return Material(
      color: colors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 48,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: 34,
                child: onLeadingPressed == null
                    ? IconTheme(
                        data: IconThemeData(
                          color: onChanged == null
                              ? colors.onSurface.withValues(alpha: 0.38)
                              : colors.onSurfaceVariant,
                          size: 18,
                        ),
                        child: Center(child: leading),
                      )
                    : IconButton(
                        tooltip: 'Mute or unmute',
                        onPressed: onLeadingPressed,
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        icon: leading,
                      ),
              ),
              Expanded(child: slider),
              SizedBox.square(
                dimension: 34,
                child: IconTheme(
                  data: IconThemeData(color: colors.onSurfaceVariant, size: 18),
                  child: Center(child: trailing),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
Widget buildPowerProfileGroupForTest({
  required String selectedProfile,
  required ValueChanged<String> onChanged,
}) {
  return _PowerProfileGroup(
    selectedProfile: selectedProfile,
    onChanged: onChanged,
  );
}

class _PowerProfileGroup extends StatelessWidget {
  const _PowerProfileGroup({
    required this.selectedProfile,
    required this.onChanged,
  });

  final String selectedProfile;
  final ValueChanged<String> onChanged;

  static const List<_PowerProfileChoice> _profiles = <_PowerProfileChoice>[
    _PowerProfileChoice(
      value: 'power-saver',
      label: 'Saver',
      icon: Icons.eco_rounded,
      semantics: 'Power saver',
    ),
    _PowerProfileChoice(
      value: 'balanced',
      label: 'Balanced',
      icon: Icons.balance_rounded,
      semantics: 'Balanced',
    ),
    _PowerProfileChoice(
      value: 'performance',
      label: 'Fast',
      icon: Icons.speed_rounded,
      semantics: 'Performance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _profiles.indexWhere(
      (_PowerProfileChoice profile) => profile.value == selectedProfile,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double groupWidth = constraints.maxWidth;
        // m3e_buttons adds approximately four logical pixels of connected

        // seam geometry beyond the configured segment widths. Reserve it

        // so the trailing edge stays inside the parent constraints.

        const double connectedGroupWidthOverhead = 4;

        final double segmentWidth =
            (groupWidth - connectedGroupWidthOverhead) / _profiles.length;

        return SizedBox(
          key: const ValueKey<String>('power-profile-group-bounds'),
          width: groupWidth,
          height: 56,
          child: M3EToggleButtonGroup(
            type: M3EButtonGroupType.connected,
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.custom(
              width: segmentWidth,
              height: 56,
              hPadding: 10,
              iconSize: 18,
              iconGap: 6,
            ),
            density: M3EButtonGroupDensity.compact,
            spacing: 0,
            expandedRatio: 0,
            overflow: M3EButtonGroupOverflow.none,
            selectedIndex: selectedIndex < 0 ? null : selectedIndex,
            semanticLabel: 'Power profile',
            actions: _profiles
                .map(
                  (_PowerProfileChoice profile) => M3EToggleButtonGroupAction(
                    icon: Icon(profile.icon),
                    label: Text(
                      profile.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    semanticLabel: profile.semantics,
                  ),
                )
                .toList(growable: false),
            onSelectedIndexChanged: (int? index) {
              if (index != null) {
                onChanged(_profiles[index].value);
              }
            },
          ),
        );
      },
    );
  }
}

class _PowerProfileChoice {
  const _PowerProfileChoice({
    required this.value,
    required this.label,
    required this.icon,
    required this.semantics,
  });

  final String value;
  final String label;
  final IconData icon;
  final String semantics;
}

class _RoundUtilityButton extends StatelessWidget {
  const _RoundUtilityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(42),
        maximumSize: const Size.square(42),
        backgroundColor: selected
            ? colors.secondaryContainer
            : colors.surfaceContainerHigh,
        foregroundColor: selected
            ? colors.onSecondaryContainer
            : colors.onSurfaceVariant,
      ),
      icon: Icon(icon),
    );
  }
}

class _NetworkSelectionPage extends StatefulWidget {
  const _NetworkSelectionPage({
    required this.initialWifiState,
    required this.onWifiChanged,
    required this.onBack,
    super.key,
  });

  final AvailabilityState initialWifiState;
  final Future<void> Function(bool enabled) onWifiChanged;
  final VoidCallback onBack;

  @override
  State<_NetworkSelectionPage> createState() => _NetworkSelectionPageState();
}

class _NetworkSelectionPageState extends State<_NetworkSelectionPage> {
  bool _loading = true;
  bool _wifiEnabled = false;
  String? _error;
  String? _busyAction;
  List<_WiredInterface> _wired = const <_WiredInterface>[];
  List<_WifiNetwork> _wireless = const <_WifiNetwork>[];

  bool get _busy => _busyAction != null;

  @override
  void initState() {
    super.initState();
    _wifiEnabled = widget.initialWifiState == AvailabilityState.enabled;
    unawaited(_reload(rescan: true));
  }

  Future<void> _reload({required bool rescan, bool showLoading = true}) async {
    if (!mounted) {
      return;
    }

    if (showLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final CommandResult radio = await runCommand('nmcli', const <String>[
        'radio',
        'wifi',
      ], timeout: const Duration(seconds: 4));
      _ensureCommandSucceeded(radio, 'Could not read the Wi-Fi radio state.');

      final bool wifiEnabled = radio.stdout.trim().toLowerCase() == 'enabled';

      final CommandResult devices = await runCommand('nmcli', const <String>[
        '--terse',
        '--escape',
        'yes',
        '--fields',
        'DEVICE,TYPE,STATE,CONNECTION',
        'device',
        'status',
      ], timeout: const Duration(seconds: 6));
      _ensureCommandSucceeded(devices, 'Could not read network interfaces.');

      CommandResult? wifi;
      if (wifiEnabled) {
        wifi = await runCommand('nmcli', <String>[
          '--terse',
          '--escape',
          'yes',
          '--fields',
          'IN-USE,SSID,SIGNAL,SECURITY',
          'device',
          'wifi',
          'list',
          '--rescan',
          rescan ? 'yes' : 'no',
        ], timeout: Duration(seconds: rescan ? 15 : 6));
        _ensureCommandSucceeded(wifi, 'Could not read wireless networks.');
      }

      final List<_WiredInterface> wired = <_WiredInterface>[];
      for (final String line in devices.stdout.split('\n')) {
        if (line.trim().isEmpty) {
          continue;
        }
        final List<String> fields = _splitNmcliFields(line);
        if (fields.length < 4 || fields[1] != 'ethernet') {
          continue;
        }
        wired.add(
          _WiredInterface(
            device: fields[0],
            state: fields[2],
            connection: fields[3],
          ),
        );
      }

      final Map<String, _WifiNetwork> networks = <String, _WifiNetwork>{};
      for (final String line in (wifi?.stdout ?? '').split('\n')) {
        if (line.trim().isEmpty) {
          continue;
        }
        final List<String> fields = _splitNmcliFields(line);
        if (fields.length < 4 || fields[1].trim().isEmpty) {
          continue;
        }
        final _WifiNetwork candidate = _WifiNetwork(
          active: fields[0] == '*',
          ssid: fields[1],
          signal: int.tryParse(fields[2]) ?? 0,
          security: fields[3],
        );
        final _WifiNetwork? existing = networks[candidate.ssid];
        if (existing == null ||
            candidate.active ||
            candidate.signal > existing.signal) {
          networks[candidate.ssid] = candidate;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _wifiEnabled = wifiEnabled;
        _wired = wired;
        _wireless = networks.values.toList(growable: false)
          ..sort((_WifiNetwork a, _WifiNetwork b) {
            if (a.active != b.active) {
              return a.active ? -1 : 1;
            }
            return b.signal.compareTo(a.signal);
          });
        _loading = false;
        _error = null;
      });
    } on CommandTimeoutException catch (error) {
      _setLoadError(error.toString());
    } on ProcessException catch (error) {
      _setLoadError('NetworkManager tools are unavailable: ${error.message}');
    } on _CommandFailure catch (error) {
      _setLoadError(error.message);
    }
  }

  void _setLoadError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _error = message;
    });
  }

  Future<void> _runBusy(String action, Future<void> Function() callback) async {
    if (_busy || !mounted) {
      return;
    }

    setState(() => _busyAction = action);
    try {
      await callback();
    } on CommandTimeoutException catch (error) {
      if (mounted) {
        _showError(error.toString());
      }
    } on ProcessException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } on _CommandFailure catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _setWifi(bool enabled) {
    return _runBusy('wifi-switch', () async {
      await widget.onWifiChanged(enabled);
      if (!mounted) {
        return;
      }
      await _reload(rescan: false, showLoading: false);
    });
  }

  Future<void> _toggleWired(_WiredInterface item) {
    final String action = 'wired:${item.device}';
    return _runBusy(action, () async {
      final bool connected = item.state == 'connected';
      final CommandResult result = await runCommand(
        'nmcli',
        connected
            ? <String>['device', 'disconnect', item.device]
            : <String>['device', 'connect', item.device],
        timeout: const Duration(seconds: 10),
      );
      _ensureCommandSucceeded(result, 'The wired-network action failed.');
      if (!mounted) {
        return;
      }
      await _reload(rescan: false, showLoading: false);
    });
  }

  Future<void> _connectWifi(_WifiNetwork item) {
    if (item.active) {
      return Future<void>.value();
    }

    final String action = 'wifi:${item.ssid}';
    return _runBusy(action, () async {
      CommandResult result = await runCommand('nmcli', <String>[
        'connection',
        'up',
        'id',
        item.ssid,
      ], timeout: const Duration(seconds: 12));

      final bool openNetwork =
          item.security.trim().isEmpty || item.security.trim() == '--';
      if (!result.succeeded && openNetwork) {
        result = await runCommand('nmcli', <String>[
          'device',
          'wifi',
          'connect',
          item.ssid,
        ], timeout: const Duration(seconds: 15));
      }

      if (!result.succeeded) {
        throw _CommandFailure(
          openNetwork
              ? _commandMessage(result, 'The Wi-Fi action failed.')
              : 'This secured network needs saved credentials. '
                    'Connect once in NetworkManager settings, then select it '
                    'here.',
        );
      }

      if (!mounted) {
        return;
      }
      await _reload(rescan: false, showLoading: false);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.isEmpty ? 'The network action failed.' : message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _DetailPageFrame(
      title: 'Network',
      onBack: widget.onBack,
      subtitle: 'Choose between wired and wireless connections',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                _SheetSectionTitle(
                  title: 'Wired',
                  trailing: _busyAction == 'refresh'
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          tooltip: 'Refresh and rescan',
                          onPressed: _busy
                              ? null
                              : () => unawaited(
                                  _runBusy(
                                    'refresh',
                                    () => _reload(
                                      rescan: true,
                                      showLoading: false,
                                    ),
                                  ),
                                ),
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                ),
                if (_wired.isEmpty)
                  const _EmptyDetailRow(
                    icon: Icons.lan_rounded,
                    title: 'No wired interface detected',
                  )
                else
                  ..._wired.map((_WiredInterface item) {
                    final String action = 'wired:${item.device}';
                    return ListTile(
                      key: ValueKey<String>(action),
                      leading: const Icon(Icons.lan_rounded),
                      title: Text(
                        item.connection == '--' ? item.device : item.connection,
                      ),
                      subtitle: Text(
                        item.state == 'connected'
                            ? '${item.device} · Connected'
                            : '${item.device} · ${item.state}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _busyAction == action
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : item.state == 'connected'
                          ? const Icon(Icons.check_rounded)
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: _busy ? null : () => _toggleWired(item),
                    );
                  }),
                const SizedBox(height: 10),
                _SheetSectionTitle(
                  title: 'Wi-Fi',
                  trailing: Switch(
                    value: _wifiEnabled,
                    onChanged: _busy ? null : _setWifi,
                  ),
                ),
                if (!_wifiEnabled)
                  const _EmptyDetailRow(
                    icon: Icons.wifi_off_rounded,
                    title: 'Wi-Fi is off',
                  )
                else if (_wireless.isEmpty)
                  const _EmptyDetailRow(
                    icon: Icons.wifi_find_rounded,
                    title: 'No wireless networks found',
                  )
                else
                  ..._wireless.map((_WifiNetwork item) {
                    final String action = 'wifi:${item.ssid}';
                    return ListTile(
                      key: ValueKey<String>(action),
                      leading: Icon(_wifiSignalIcon(item.signal)),
                      title: Text(item.ssid),
                      subtitle: Text(
                        <String>[
                          '${item.signal}%',
                          if (item.security.trim().isNotEmpty &&
                              item.security.trim() != '--')
                            item.security,
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: _busyAction == action
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : item.active
                          ? const Icon(Icons.check_rounded)
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: _busy ? null : () => _connectWifi(item),
                    );
                  }),
              ],
            ),
    );
  }
}

class _BluetoothSelectionPage extends StatefulWidget {
  const _BluetoothSelectionPage({
    required this.initialState,
    required this.onEnabledChanged,
    required this.onBack,
    super.key,
  });

  final AvailabilityState initialState;
  final Future<void> Function(bool enabled) onEnabledChanged;
  final VoidCallback onBack;

  @override
  State<_BluetoothSelectionPage> createState() =>
      _BluetoothSelectionPageState();
}

class _BluetoothSelectionPageState extends State<_BluetoothSelectionPage> {
  bool _loading = true;
  bool _enabled = false;
  String? _error;
  String? _busyAction;
  List<_BluetoothDevice> _devices = const <_BluetoothDevice>[];
  Set<String> _connected = const <String>{};

  bool get _busy => _busyAction != null;

  @override
  void initState() {
    super.initState();
    _enabled = widget.initialState == AvailabilityState.enabled;
    unawaited(_reload());
  }

  Future<void> _reload({bool showLoading = true}) async {
    if (!mounted) {
      return;
    }

    if (showLoading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final List<CommandResult> results = await Future.wait<CommandResult>(
        <Future<CommandResult>>[
          runCommand('bluetoothctl', const <String>[
            'devices',
            'Paired',
          ], timeout: const Duration(seconds: 6)),
          runCommand('bluetoothctl', const <String>[
            'devices',
            'Connected',
          ], timeout: const Duration(seconds: 6)),
        ],
      );

      _ensureCommandSucceeded(
        results[0],
        'Could not read paired Bluetooth devices.',
      );
      _ensureCommandSucceeded(
        results[1],
        'Could not read connected Bluetooth devices.',
      );

      final List<_BluetoothDevice> devices = _parseBluetoothDevices(
        results[0].stdout,
      );
      final Set<String> active = _parseBluetoothDevices(
        results[1].stdout,
      ).map((_BluetoothDevice item) => item.address).toSet();

      if (!mounted) {
        return;
      }

      setState(() {
        _devices = devices;
        _connected = active;
        _loading = false;
        _error = null;
      });
    } on CommandTimeoutException catch (error) {
      _setLoadError(error.toString());
    } on ProcessException catch (error) {
      _setLoadError('Bluetooth tools are unavailable: ${error.message}');
    } on _CommandFailure catch (error) {
      _setLoadError(error.message);
    }
  }

  void _setLoadError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _error = message;
    });
  }

  Future<void> _runBusy(String action, Future<void> Function() callback) async {
    if (_busy || !mounted) {
      return;
    }

    setState(() => _busyAction = action);
    try {
      await callback();
    } on CommandTimeoutException catch (error) {
      if (mounted) {
        _showError(error.toString());
      }
    } on ProcessException catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } on _CommandFailure catch (error) {
      if (mounted) {
        _showError(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _busyAction = null);
      }
    }
  }

  Future<void> _setEnabled(bool enabled) {
    return _runBusy('bluetooth-switch', () async {
      await widget.onEnabledChanged(enabled);
      if (!mounted) {
        return;
      }
      setState(() => _enabled = enabled);
      await _reload(showLoading: false);
    });
  }

  Future<void> _toggleDevice(_BluetoothDevice item) {
    final String action = 'bluetooth:${item.address}';
    return _runBusy(action, () async {
      final bool connected = _connected.contains(item.address);
      final CommandResult result = await runCommand('bluetoothctl', <String>[
        connected ? 'disconnect' : 'connect',
        item.address,
      ], timeout: const Duration(seconds: 12));
      _ensureCommandSucceeded(result, 'The Bluetooth action failed.');
      if (!mounted) {
        return;
      }
      await _reload(showLoading: false);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isEmpty ? 'The Bluetooth action failed.' : message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _DetailPageFrame(
      title: 'Bluetooth',
      onBack: widget.onBack,
      subtitle: 'Connect or disconnect a paired device',
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SwitchListTile(
            title: const Text('Use Bluetooth'),
            value: _enabled,
            onChanged: _busy || _loading ? null : _setEnabled,
            secondary: _busyAction == 'bluetooth-switch'
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (!_enabled)
            const _EmptyDetailRow(
              icon: Icons.bluetooth_disabled_rounded,
              title: 'Bluetooth is off',
            )
          else if (_devices.isEmpty)
            const _EmptyDetailRow(
              icon: Icons.bluetooth_searching_rounded,
              title: 'No paired devices',
            )
          else
            ..._devices.map((_BluetoothDevice item) {
              final bool connected = _connected.contains(item.address);
              final String action = 'bluetooth:${item.address}';
              return ListTile(
                key: ValueKey<String>(action),
                leading: const Icon(Icons.bluetooth_rounded),
                title: Text(item.name),
                subtitle: Text(connected ? 'Connected' : 'Paired'),
                trailing: _busyAction == action
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : connected
                    ? const Icon(Icons.check_rounded)
                    : const Icon(Icons.chevron_right_rounded),
                onTap: _busy ? null : () => _toggleDevice(item),
              );
            }),
        ],
      ),
    );
  }
}

class _ThemeDetailPage extends StatefulWidget {
  const _ThemeDetailPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final MotionController controller;
  final VoidCallback onBack;

  @override
  State<_ThemeDetailPage> createState() => _ThemeDetailPageState();
}

class _ThemeDetailPageState extends State<_ThemeDetailPage> {
  late ThemeMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.controller.themeMode;
  }

  void _selectMode(ThemeMode mode) {
    setState(() => _selectedMode = mode);
    widget.controller.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return _DetailPageFrame(
      title: 'Theme',
      subtitle: 'Choose how Motion Shell follows the system appearance',
      onBack: widget.onBack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: ThemeMode.values
            .map(
              (ThemeMode mode) => ListTile(
                key: ValueKey<ThemeMode>(mode),
                leading: Icon(_themeModeIcon(mode)),
                title: Text(_themeModeTitle(mode)),
                subtitle: Text(
                  _themeModeDescription(mode),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: _selectedMode == mode,
                trailing: _selectedMode == mode
                    ? const Icon(Icons.check_rounded)
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () => _selectMode(mode),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _AudioDeviceDetailPage extends StatelessWidget {
  const _AudioDeviceDetailPage({
    required this.title,
    required this.endpoint,
    required this.icon,
    required this.onSelected,
    required this.onBack,
    super.key,
  });

  final String title;
  final AudioEndpointSnapshot endpoint;
  final IconData icon;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _DetailPageFrame(
      title: title,
      subtitle: 'Choose the active device',
      onBack: onBack,
      child: endpoint.devices.isEmpty
          ? _EmptyDetailRow(icon: icon, title: 'No devices available')
          : ListView(
              padding: EdgeInsets.zero,
              children: endpoint.devices
                  .map((AudioDevice device) {
                    final bool selected =
                        device.id == endpoint.selectedDeviceId ||
                        (endpoint.selectedDeviceId == null && device.isDefault);

                    return ListTile(
                      key: ValueKey<String>('audio:${device.id}'),
                      leading: Icon(icon),
                      title: Text(
                        device.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: device.isDefault
                          ? const Text('System default')
                          : null,
                      selected: selected,
                      trailing: selected
                          ? const Icon(Icons.check_rounded)
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: () => onSelected(device.id),
                    );
                  })
                  .toList(growable: false),
            ),
    );
  }
}

class _SessionDetailPage extends StatefulWidget {
  const _SessionDetailPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final MotionController controller;
  final VoidCallback onBack;

  @override
  State<_SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<_SessionDetailPage> {
  static const List<_SessionActionSpec> _actions = <_SessionActionSpec>[
    _SessionActionSpec(
      action: 'lock',
      icon: Icons.lock_rounded,
      title: 'Lock',
      subtitle: 'Lock the current session',
    ),
    _SessionActionSpec(
      action: 'suspend',
      icon: Icons.bedtime_rounded,
      title: 'Suspend',
      subtitle: 'Put the computer to sleep',
    ),
    _SessionActionSpec(
      action: 'logout',
      icon: Icons.logout_rounded,
      title: 'Log out',
      subtitle: 'End the current desktop session',
    ),
    _SessionActionSpec(
      action: 'reboot',
      icon: Icons.restart_alt_rounded,
      title: 'Restart',
      subtitle: 'Restart the computer',
    ),
    _SessionActionSpec(
      action: 'poweroff',
      icon: Icons.power_settings_new_rounded,
      title: 'Shut down',
      subtitle: 'Power off the computer',
    ),
  ];

  String? _busyAction;
  String? _error;

  bool get _busy => _busyAction != null;

  bool _requiresConfirmation(_SessionActionSpec item) {
    return switch (item.action) {
      'logout' || 'reboot' || 'poweroff' => true,
      _ => false,
    };
  }

  Future<bool> _confirmAction(_SessionActionSpec item) async {
    if (!_requiresConfirmation(item)) {
      return true;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: Icon(item.icon),
        title: Text('${item.title}?'),
        content: Text(switch (item.action) {
          'logout' => 'Open applications may have unsaved work. Log out now?',
          'reboot' => 'Open applications may have unsaved work. Restart now?',
          'poweroff' =>
            'Open applications may have unsaved work. Shut down now?',
          _ => item.subtitle,
        }),
        actions: <Widget>[
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(item.title),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _runAction(_SessionActionSpec item) async {
    if (_busy || !await _confirmAction(item) || !mounted) {
      return;
    }

    setState(() {
      _busyAction = item.action;
      _error = null;
    });

    try {
      await widget.controller.sessionAction(item.action);
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _busyAction = null;
        _error = error.toString();
      });
      return;
    }

    if (mounted) {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _DetailPageFrame(
      title: 'Power and session',
      subtitle: 'Lock, suspend, sign out, restart, or shut down',
      onBack: widget.onBack,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                _error!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ..._actions.map(
            (_SessionActionSpec item) => ListTile(
              key: ValueKey<String>('session:${item.action}'),
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _busyAction == item.action
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              enabled: !_busy,
              onTap: _busy ? null : () => _runAction(item),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionActionSpec {
  const _SessionActionSpec({
    required this.action,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String action;
  final IconData icon;
  final String title;
  final String subtitle;
}

class _DetailPageFrame extends StatelessWidget {
  const _DetailPageFrame({
    required this.title,
    required this.child,
    required this.onBack,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              onBack();
              return null;
            },
          ),
        },
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: title,
          child: Material(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 70),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            autofocus: true,
                            tooltip: 'Back',
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 52),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (subtitle != null) ...<Widget>[
                                const SizedBox(height: 3),
                                Text(
                                  subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    height: 1.18,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetSectionTitle extends StatelessWidget {
  const _SheetSectionTitle({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        trailing,
      ],
    );
  }
}

class _EmptyDetailRow extends StatelessWidget {
  const _EmptyDetailRow({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(enabled: false, leading: Icon(icon), title: Text(title));
  }
}

class _NetworkOverview {
  const _NetworkOverview({
    required this.icon,
    required this.subtitle,
    required this.selected,
  });

  final IconData icon;
  final String subtitle;
  final bool selected;
}

class _WiredInterface {
  const _WiredInterface({
    required this.device,
    required this.state,
    required this.connection,
  });

  final String device;
  final String state;
  final String connection;
}

class _WifiNetwork {
  const _WifiNetwork({
    required this.active,
    required this.ssid,
    required this.signal,
    required this.security,
  });

  final bool active;
  final String ssid;
  final int signal;
  final String security;
}

class _BluetoothDevice {
  const _BluetoothDevice({required this.address, required this.name});

  final String address;
  final String name;
}

Future<_NetworkOverview> _readNetworkOverview() async {
  try {
    final CommandResult result = await runCommand('nmcli', const <String>[
      '--terse',
      '--escape',
      'yes',
      '--fields',
      'TYPE,STATE,CONNECTION',
      'device',
      'status',
    ], timeout: const Duration(seconds: 4));

    if (!result.succeeded) {
      return const _NetworkOverview(
        icon: Icons.language_rounded,
        subtitle: 'Wired or wireless',
        selected: false,
      );
    }

    String? wifiConnection;
    for (final String line in result.stdout.split('\n')) {
      if (line.trim().isEmpty) {
        continue;
      }
      final List<String> fields = _splitNmcliFields(line);
      if (fields.length < 3 || fields[1] != 'connected') {
        continue;
      }
      if (fields[0] == 'ethernet') {
        return _NetworkOverview(
          icon: Icons.lan_rounded,
          subtitle: 'Ethernet · ${fields[2]}',
          selected: true,
        );
      }
      if (fields[0] == 'wifi') {
        wifiConnection = fields[2];
      }
    }

    if (wifiConnection != null) {
      return _NetworkOverview(
        icon: Icons.wifi_rounded,
        subtitle: 'Wi-Fi · $wifiConnection',
        selected: true,
      );
    }
  } on CommandTimeoutException {
    // Fall through to the stable disconnected representation.
  } on ProcessException {
    // Fall through to the stable disconnected representation.
  }

  return const _NetworkOverview(
    icon: Icons.language_rounded,
    subtitle: 'Wired or wireless',
    selected: false,
  );
}

List<String> _splitNmcliFields(String line) {
  final List<String> fields = <String>[];
  final StringBuffer current = StringBuffer();
  bool escaped = false;

  for (final int codeUnit in line.codeUnits) {
    final String character = String.fromCharCode(codeUnit);
    if (escaped) {
      current.write(character);
      escaped = false;
    } else if (character == r'\') {
      escaped = true;
    } else if (character == ':') {
      fields.add(current.toString());
      current.clear();
    } else {
      current.write(character);
    }
  }

  fields.add(current.toString());
  return fields;
}

List<_BluetoothDevice> _parseBluetoothDevices(String output) {
  final List<_BluetoothDevice> devices = <_BluetoothDevice>[];
  for (final String line in output.split('\n')) {
    final RegExpMatch? match = RegExp(
      r'^Device\s+([0-9A-Fa-f:]{17})\s+(.+)$',
    ).firstMatch(line.trim());
    if (match == null) {
      continue;
    }
    devices.add(
      _BluetoothDevice(address: match.group(1)!, name: match.group(2)!),
    );
  }
  return devices;
}

IconData _wifiSignalIcon(int signal) {
  if (signal >= 75) {
    return Icons.network_wifi_rounded;
  }
  if (signal >= 45) {
    return Icons.network_wifi_2_bar_rounded;
  }
  return Icons.network_wifi_1_bar_rounded;
}

String _audioDeviceLabel(AudioEndpointSnapshot endpoint) {
  return endpoint.selectedDevice?.name ?? 'No device';
}

String _availabilityLabel(AvailabilityState state, {required String enabled}) {
  return switch (state) {
    AvailabilityState.enabled => enabled,
    AvailabilityState.disabled => 'Off',
    AvailabilityState.unavailable => 'Unavailable',
    AvailabilityState.loading => 'Updating…',
    AvailabilityState.error => 'Needs attention',
    AvailabilityState.unknown => 'Checking…',
  };
}

class _CommandFailure implements Exception {
  const _CommandFailure(this.message);

  final String message;
}

void _ensureCommandSucceeded(CommandResult result, String fallback) {
  if (!result.succeeded) {
    throw _CommandFailure(_commandMessage(result, fallback));
  }
}

String _commandMessage(CommandResult result, String fallback) {
  final String stderr = result.stderr.trim();
  if (stderr.isNotEmpty) {
    return stderr;
  }
  final String stdout = result.stdout.trim();
  return stdout.isEmpty ? fallback : stdout;
}

IconData _themeModeIcon(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => Icons.brightness_auto_rounded,
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
  };
}

String _themeModeDescription(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'Use the current desktop appearance',
    ThemeMode.light => 'Always use the light palette',
    ThemeMode.dark => 'Always use the dark palette',
  };
}

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Off',
    ThemeMode.dark => 'On',
  };
}

String _themeModeTitle(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'Follow system',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}

Future<void> _showErrorDialog(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      icon: const Icon(Icons.error_outline_rounded),
      title: const Text('A system control failed'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<void> _showSettingsPlaceholder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Settings'),
      content: const Text(
        'The full Motion Shell settings surface will open here.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
