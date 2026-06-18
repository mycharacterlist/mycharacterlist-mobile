import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image_viewer.dart';

class CharacterImage extends StatefulWidget {
  const CharacterImage({
    super.key,
    required this.imagePath,
    this.characterFolder,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIconSize = 80,
    this.showPlaceholderBorder = false,
    this.enableFullscreenPreview = false,
  });

  final String? imagePath;
  final String? characterFolder;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double placeholderIconSize;
  final bool showPlaceholderBorder;
  final bool enableFullscreenPreview;

  @override
  State<CharacterImage> createState() => _CharacterImageState();
}

class _CharacterImageState extends State<CharacterImage> {
  final _fileStorage = LocalFileStorage();
  String? _resolvedPath;

  @override
  void initState() {
    super.initState();
    _resolvePath();
  }

  @override
  void didUpdateWidget(CharacterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.characterFolder != widget.characterFolder) {
      _resolvePath();
    }
  }

  Future<void> _resolvePath() async {
    final path = widget.imagePath;
    if (path == null || path.trim().isEmpty) {
      if (mounted) {
        setState(() => _resolvedPath = null);
      }
      return;
    }

    final resolved = await _fileStorage.resolveExistingImagePath(
      path,
      characterFolder: widget.characterFolder,
    );

    if (mounted) {
      setState(() => _resolvedPath = resolved);
    }
  }

  bool get _hasFile {
    final path = _resolvedPath;
    return path != null && path.isNotEmpty && File(path).existsSync();
  }

  Widget _wrapPreview(BuildContext context, Widget child) {
    if (!widget.enableFullscreenPreview || !_hasFile) {
      return child;
    }

    return GestureDetector(
      onTap: () => CharacterImageViewer.open(context, _resolvedPath!),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasFile) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: widget.showPlaceholderBorder
            ? BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
              )
            : null,
        child: Center(
          child: Icon(
            Icons.person_outline,
            size: widget.placeholderIconSize,
            color: Colors.black38,
          ),
        ),
      );
    }

    final image = Image.file(
      File(_resolvedPath!),
      fit: widget.fit,
      cacheWidth: AppImageCache.decodeCacheWidthForBox(
        width: widget.width,
        height: widget.height,
        context: context,
      ),
      gaplessPlayback: true,
    );

    if (widget.width != null || widget.height != null) {
      return _wrapPreview(
        context,
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: image,
        ),
      );
    }

    return _wrapPreview(context, image);
  }
}
