
import 'motion_layer_shell_platform_interface.dart';

class MotionLayerShell {
  Future<String?> getPlatformVersion() {
    return MotionLayerShellPlatform.instance.getPlatformVersion();
  }
}
