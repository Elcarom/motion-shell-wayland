import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as image;
import 'package:material_color_utilities/material_color_utilities.dart';

class WallpaperPalette {
  const WallpaperPalette({
    required this.seedArgb,
    required this.candidatesArgb,
    required this.sourcePath,
  });

  final int seedArgb;
  final List<int> candidatesArgb;
  final String? sourcePath;
}

class DynamicColorService {
  const DynamicColorService();

  static const int fallbackSeedArgb = 0xFF6750A4;

  Future<WallpaperPalette> extract(String? path) async {
    if (path == null || path.isEmpty) {
      return const WallpaperPalette(
        seedArgb: fallbackSeedArgb,
        candidatesArgb: <int>[fallbackSeedArgb],
        sourcePath: null,
      );
    }
    final File file = File(path);
    if (!await file.exists()) {
      return WallpaperPalette(
        seedArgb: fallbackSeedArgb,
        candidatesArgb: const <int>[fallbackSeedArgb],
        sourcePath: path,
      );
    }
    try {
      final Uint8List bytes = await file.readAsBytes();
      final image.Image? decoded = image.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unsupported wallpaper format');
      }
      final image.Image sample = image.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? 128 : null,
        height: decoded.height > decoded.width ? 128 : null,
        interpolation: image.Interpolation.average,
      );
      final List<int> pixels = <int>[];
      for (int y = 0; y < sample.height; y += 2) {
        for (int x = 0; x < sample.width; x += 2) {
          final image.Pixel pixel = sample.getPixel(x, y);
          if (pixel.a < 220) {
            continue;
          }
          pixels.add(
            0xFF000000 |
                (pixel.r.toInt() << 16) |
                (pixel.g.toInt() << 8) |
                pixel.b.toInt(),
          );
        }
      }
      final QuantizerResult quantized = await QuantizerCelebi().quantize(
        pixels,
        96,
      );
      final List<int> ranked = Score.score(
        quantized.colorToCount,
        desired: 6,
        fallbackColorARGB: fallbackSeedArgb,
      );
      return WallpaperPalette(
        seedArgb: ranked.firstOrNull ?? fallbackSeedArgb,
        candidatesArgb: ranked.isEmpty ? const <int>[fallbackSeedArgb] : ranked,
        sourcePath: path,
      );
    } on Object {
      return WallpaperPalette(
        seedArgb: fallbackSeedArgb,
        candidatesArgb: const <int>[fallbackSeedArgb],
        sourcePath: path,
      );
    }
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
