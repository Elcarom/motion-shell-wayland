import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'motion_layer_shell_method_channel.dart';

abstract class MotionLayerShellPlatform extends PlatformInterface {
  /// Constructs a MotionLayerShellPlatform.
  MotionLayerShellPlatform() : super(token: _token);

  static final Object _token = Object();

  static MotionLayerShellPlatform _instance = MethodChannelMotionLayerShell();

  /// The default instance of [MotionLayerShellPlatform] to use.
  ///
  /// Defaults to [MethodChannelMotionLayerShell].
  static MotionLayerShellPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MotionLayerShellPlatform] when
  /// they register themselves.
  static set instance(MotionLayerShellPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
