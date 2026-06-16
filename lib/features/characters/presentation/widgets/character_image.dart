import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image_viewer.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 80,
    this.showPlaceholderBorder = false,
    this.enableFullscreenPreview = false,
  });

  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double placeholderIconSize;
  final bool showPlaceholderBorder;
  final bool enableFullscreenPreview;

  bool get _hasFile {
    final path = imagePath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  Widget _wrapPreview(BuildContext context, Widget child) {
    if (!enableFullscreenPreview || !_hasFile) {
      return child;
    }

    return GestureDetector(
      onTap: () => CharacterImageViewer.open(context, imagePath!),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasFile) {
      return Container(
        width: width,
        height: height,
        decoration: showPlaceholderBorder
            ? BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
              )
            : null,
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: placeholderIconSize,
            color: Colors.black38,
          ),
        ),
      );
    }

    final image = Image.file(
      File(imagePath!),
      fit: fit,
      cacheWidth: width != null
          ? AppImageCache.decodeCacheDimension(width!, context)
          : null,
      cacheHeight: height != null
          ? AppImageCache.decodeCacheDimension(height!, context)
          : null,
      gaplessPlayback: true,
    );

    if (width != null || height != null) {
      return _wrapPreview(
        context,
        SizedBox(
          width: width,
          height: height,
          child: image,
        ),
      );
    }

    return _wrapPreview(context, image);
  }
}
