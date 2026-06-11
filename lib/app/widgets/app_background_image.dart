import 'package:flutter/material.dart';

class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.cover,
  });

  final String assetPath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      alignment: Alignment.center,
    );
  }
}
