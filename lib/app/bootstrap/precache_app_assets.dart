import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';

Future<void> precacheAppBackgrounds(BuildContext context) async {
  if (!AppImageCache.isWarmedUp) {
    await AppImageCache.warmUp();
  }

  await Future.wait(
    AppBackgroundAssets.all.map(
      (assetPath) => precacheImage(AssetImage(assetPath), context),
    ),
  );
}
