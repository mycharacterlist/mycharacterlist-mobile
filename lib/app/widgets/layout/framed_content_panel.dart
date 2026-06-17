import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/layout/app_background_image.dart';

/// Centered decorative frame with scrollable or fixed content inside.
class FramedContentPanel extends StatelessWidget {
  const FramedContentPanel({
    super.key,
    required this.frameAssetPath,
    required this.child,
    this.widthFactor = 0.95,
    this.heightFactor = 0.87,
    this.contentPadding = const EdgeInsets.only(
      top: 0,
      left: 8,
      right: 8,
      bottom: 20,
    ),
  });

  final String frameAssetPath;
  final Widget child;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets contentPadding;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final panelWidth = size.width * widthFactor;
    final panelHeight = size.height * heightFactor;

    return Center(
      child: SizedBox(
        width: panelWidth,
        height: panelHeight,
        child: Stack(
          children: [
            Positioned.fill(
              child: AppBackgroundImage(
                assetPath: frameAssetPath,
                fit: BoxFit.fill,
              ),
            ),
            Positioned(
              top: contentPadding.top,
              left: contentPadding.left,
              right: contentPadding.right,
              bottom: contentPadding.bottom,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
