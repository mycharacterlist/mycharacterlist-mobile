import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';

Future<void> precacheAppBackgrounds(BuildContext context) async {
  await Future.wait(
    AppBackgroundAssets.all.map(
      (assetPath) => precacheImage(AssetImage(assetPath), context),
    ),
  );
}
