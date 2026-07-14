import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'motion_layer_shell_platform_interface.dart';

/// An implementation of [MotionLayerShellPlatform] that uses method channels.
class MethodChannelMotionLayerShell extends MotionLayerShellPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('motion_layer_shell');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
