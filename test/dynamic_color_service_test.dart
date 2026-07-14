import 'package:flutter_test/flutter_test.dart';
import 'package:motion_shell/core/theme/dynamic_color_service.dart';

void main() {
  test('missing wallpaper returns a stable fallback', () async {
    final WallpaperPalette palette = await const DynamicColorService().extract(
      '/definitely/missing/wallpaper.png',
    );
    expect(palette.seedArgb, DynamicColorService.fallbackSeedArgb);
    expect(palette.candidatesArgb, isNotEmpty);
  });
}
