import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/layout/app_background_image.dart';

/// Full-screen background image with layered foreground widgets.
class BackgroundStack extends StatelessWidget {
  const BackgroundStack({
    super.key,
    required this.backgroundAssetPath,
    required this.children,
    this.fit = BoxFit.cover,
  });

  final String backgroundAssetPath;
  final List<Widget> children;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AppBackgroundImage(
            assetPath: backgroundAssetPath,
            fit: fit,
          ),
        ),
        ...children,
      ],
    );
  }
}
