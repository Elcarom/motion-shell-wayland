import 'package:wayland_layer_shell/types.dart';
import 'package:wayland_layer_shell/wayland_layer_shell.dart';

import '../../surfaces/surface_kind.dart';

abstract interface class LayerSurfaceHost {
  Future<bool> configure(SurfaceKind kind);
}

class WaylandLayerSurfaceHost implements LayerSurfaceHost {
  WaylandLayerSurfaceHost({WaylandLayerShell? plugin})
    : _plugin = plugin ?? WaylandLayerShell();

  final WaylandLayerShell _plugin;

  @override
  Future<bool> configure(SurfaceKind kind) async {
    if (kind == SurfaceKind.showcase || kind == SurfaceKind.settings) {
      return false;
    }
    final _SurfaceSpec spec = _SurfaceSpec.forKind(kind);

    final bool initialized = await _plugin.initialize(spec.width, spec.height);
    if (!initialized) {
      return false;
    }
    await _plugin.setLayer(spec.layer);
    await _plugin.setKeyboardMode(spec.keyboardMode);
    await _plugin.setAnchor(ShellEdge.edgeTop, spec.top);
    await _plugin.setAnchor(ShellEdge.edgeRight, spec.right);
    await _plugin.setAnchor(ShellEdge.edgeBottom, spec.bottom);
    await _plugin.setAnchor(ShellEdge.edgeLeft, spec.left);
    for (final MapEntry<ShellEdge, int> margin in spec.margins.entries) {
      await _plugin.setMargin(margin.key, margin.value);
    }
    if (spec.autoExclusive) {
      await _plugin.enableAutoExclusiveZone();
    } else {
      await _plugin.setExclusiveZone(spec.exclusiveZone);
    }
    return true;
  }
}

class _SurfaceSpec {
  const _SurfaceSpec({
    required this.width,
    required this.height,
    required this.layer,
    required this.keyboardMode,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.margins,
    this.autoExclusive = false,
  }) : exclusiveZone = 0;

  factory _SurfaceSpec.forKind(SurfaceKind kind) {
    return switch (kind) {
      SurfaceKind.bar => const _SurfaceSpec(
        width: 1920,
        height: 64,
        layer: ShellLayer.layerTop,
        keyboardMode: ShellKeyboardMode.keyboardModeNone,
        top: true,
        right: true,
        bottom: false,
        left: true,
        margins: <ShellEdge, int>{
          ShellEdge.edgeTop: 8,
          ShellEdge.edgeLeft: 12,
          ShellEdge.edgeRight: 12,
        },
        autoExclusive: true,
      ),
      SurfaceKind.osd => const _SurfaceSpec(
        width: 420,
        height: 112,
        layer: ShellLayer.layerOverlay,
        keyboardMode: ShellKeyboardMode.keyboardModeNone,
        top: false,
        right: false,
        bottom: true,
        left: false,
        margins: <ShellEdge, int>{ShellEdge.edgeBottom: 48},
      ),
      SurfaceKind.quickSettings ||
      SurfaceKind.notifications => const _SurfaceSpec(
        width: 520,
        height: 820,
        layer: ShellLayer.layerOverlay,
        keyboardMode: ShellKeyboardMode.keyboardModeOnDemand,
        top: true,
        right: true,
        bottom: false,
        left: false,
        margins: <ShellEdge, int>{
          ShellEdge.edgeTop: 76,
          ShellEdge.edgeRight: 16,
        },
      ),
      SurfaceKind.launcher ||
      SurfaceKind.search ||
      SurfaceKind.overview => const _SurfaceSpec(
        width: 1280,
        height: 800,
        layer: ShellLayer.layerOverlay,
        keyboardMode: ShellKeyboardMode.keyboardModeExclusive,
        top: true,
        right: true,
        bottom: true,
        left: true,
        margins: <ShellEdge, int>{
          ShellEdge.edgeTop: 72,
          ShellEdge.edgeRight: 24,
          ShellEdge.edgeBottom: 24,
          ShellEdge.edgeLeft: 24,
        },
      ),
      SurfaceKind.showcase || SurfaceKind.settings => throw StateError(
        '$kind does not use layer shell',
      ),
    };
  }

  final int width;
  final int height;
  final ShellLayer layer;
  final ShellKeyboardMode keyboardMode;
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;
  final Map<ShellEdge, int> margins;
  final bool autoExclusive;
  final int exclusiveZone;
}
