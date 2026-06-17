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

  /// Use with [Image.file] / [Image.asset] when [BoxFit.cover] or
  /// [BoxFit.contain] should keep the original aspect ratio.
  ///
  /// Setting both [cacheWidth] and [cacheHeight] on [Image] forces a stretched
  /// decode size and makes photos look squished.
  static int? decodeCacheWidthForBox({
    double? width,
    double? height,
    required BuildContext context,
  }) {
    final logicalSize = _largestSide(width, height);
    if (logicalSize <= 0) {
      return null;
    }

    return decodeCacheDimension(logicalSize, context);
  }

  static int? decodeCacheWidthForBoxWithDpr({
    double? width,
    double? height,
    required double devicePixelRatio,
  }) {
    final logicalSize = _largestSide(width, height);
    if (logicalSize <= 0) {
      return null;
    }

    return decodeCacheDimensionWithDpr(logicalSize, devicePixelRatio);
  }

  static double _largestSide(double? width, double? height) {
    if (width == null && height == null) {
      return 0;
    }

    if (width == null) {
      return height!;
    }

    if (height == null) {
      return width;
    }

    return width > height ? width : height;
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
