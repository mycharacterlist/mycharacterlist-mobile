import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

/// Central place for Flutter [ImageCache] cleanup helpers.
class AppImageCache {
  AppImageCache._();

  static int decodeCacheDimension(double logicalPixels, BuildContext context) {
    return decodeCacheDimensionWithDpr(
      logicalPixels,
      MediaQuery.devicePixelRatioOf(context),
    );
  }

  static int decodeCacheDimensionWithDpr(
    double logicalPixels,
    double devicePixelRatio,
  ) {
    return (logicalPixels * devicePixelRatio).round().clamp(1, 4096);
  }

  static void evictFile(String? path) {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final file = File(path);
    if (!file.existsSync()) {
      return;
    }

    PaintingBinding.instance.imageCache.evict(FileImage(file));
  }

  /// Drops decoded images that are no longer shown on screen.
  static void trimUnused() {
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clears all decoded images. Optionally reload pinned backgrounds.
  static Future<void> clearAll({
    Future<void> Function()? restoreBackgrounds,
  }) async {
    PaintingBinding.instance.imageCache.clear();
    if (restoreBackgrounds != null) {
      await restoreBackgrounds();
    }
  }

  /// Call when leaving screens that decode many user photos.
  static void trimAfterHeavyScreen() {
    trimUnused();
  }
}
