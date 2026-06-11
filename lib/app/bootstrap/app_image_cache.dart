import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';

class AppImageCache {
  AppImageCache._();

  static final List<ui.Image> _pinnedImages = [];
  static bool _isWarmedUp = false;
  static Future<void>? _warmUpFuture;

  static Future<void> warmUp() {
    return _warmUpFuture ??= _warmUp();
  }

  static Future<void> _warmUp() async {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 200;
    imageCache.maximumSizeBytes = 256 * 1024 * 1024;

    await Future.wait(
      AppBackgroundAssets.all.map(_pinAsset),
    );

    _isWarmedUp = true;
  }

  static Future<void> _pinAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    _pinnedImages.add(frame.image);
  }

  static Future<void> refreshAfterMemoryPressure() async {
    _isWarmedUp = false;
    _warmUpFuture = null;
    await warmUp();
  }

  static bool get isWarmedUp => _isWarmedUp;
}
