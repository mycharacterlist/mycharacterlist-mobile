import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';

class CharacterImageViewer {
  const CharacterImageViewer._();

  static Future<void> open(BuildContext context, String imagePath) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close image',
      barrierColor: Colors.black.withOpacity(0.92),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _FullScreenImageViewer(imagePath: imagePath);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Future<void> openGallery(
    BuildContext context, {
    required List<String> imagePaths,
    required int initialIndex,
    String? characterFolder,
  }) {
    if (imagePaths.isEmpty) {
      return Future.value();
    }

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close image',
      barrierColor: Colors.black.withOpacity(0.92),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _FullScreenGalleryViewer(
          imagePaths: imagePaths,
          initialIndex: initialIndex,
          characterFolder: characterFolder,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class _FullScreenGalleryViewer extends StatefulWidget {
  const _FullScreenGalleryViewer({
    required this.imagePaths,
    required this.initialIndex,
    this.characterFolder,
  });

  final List<String> imagePaths;
  final int initialIndex;
  final String? characterFolder;

  @override
  State<_FullScreenGalleryViewer> createState() =>
      _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> {
  final _fileStorage = LocalFileStorage();
  PageController? _pageController;
  List<String>? _resolvedPaths;
  var _currentIndex = 0;
  var _isZoomedIn = false;
  var _isHoldingImage = false;

  bool get _controlsHidden => _isZoomedIn || _isHoldingImage;

  @override
  void initState() {
    super.initState();
    _resolvePaths();
  }

  @override
  void dispose() {
    AppImageCache.trimAfterHeavyScreen();
    _pageController?.dispose();
    super.dispose();
  }

  Future<void> _resolvePaths() async {
    final resolvedPaths = <String>[];

    for (final path in widget.imagePaths) {
      final resolved = await _fileStorage.resolveExistingImagePath(
        path,
        characterFolder: widget.characterFolder,
      );
      if (resolved != null && await File(resolved).exists()) {
        resolvedPaths.add(resolved);
      }
    }

    if (!mounted) {
      return;
    }

    final initialIndex = widget.initialIndex.clamp(
      0,
      resolvedPaths.isEmpty ? 0 : resolvedPaths.length - 1,
    ) as int;

    setState(() {
      _resolvedPaths = resolvedPaths;
      _currentIndex = initialIndex;
      _pageController = PageController(initialPage: initialIndex);
    });
  }

  void _onZoomChanged(bool isZoomedIn) {
    if (isZoomedIn != _isZoomedIn) {
      setState(() => _isZoomedIn = isZoomedIn);
    }
  }

  void _onHoldChanged(bool isHoldingImage) {
    if (isHoldingImage != _isHoldingImage) {
      setState(() => _isHoldingImage = isHoldingImage);
    }
  }

  void _goToPrevious() {
    if (_currentIndex <= 0 || _pageController == null) {
      return;
    }

    _pageController!.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _goToNext(int itemCount) {
    if (_currentIndex >= itemCount - 1 || _pageController == null) {
      return;
    }

    _pageController!.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paths = _resolvedPaths;
    final controller = _pageController;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (paths == null || controller == null)
            const AppLoadingIndicator(color: Colors.white)
          else if (paths.isEmpty)
            const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white,
                size: 56,
              ),
            )
          else
            PageView.builder(
              controller: controller,
              physics: _isZoomedIn
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              itemCount: paths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _isZoomedIn = false;
                  _isHoldingImage = false;
                });
              },
              itemBuilder: (context, index) {
                return _ZoomableImagePage(
                  imagePath: paths[index],
                  onZoomChanged: _onZoomChanged,
                  onHoldChanged: _onHoldChanged,
                );
              },
            ),
          if (!_controlsHidden && paths != null && paths.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _currentIndex == 0 ? null : _goToPrevious,
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: _currentIndex == paths.length - 1
                      ? null
                      : () => _goToNext(paths.length),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding + 18,
              child: Text(
                '${_currentIndex + 1} / ${paths.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (!_controlsHidden)
            Positioned(
              top: topPadding + 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({required this.imagePath});

  final String imagePath;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  var _isZoomedIn = false;
  var _isHoldingImage = false;

  @override
  void dispose() {
    AppImageCache.trimAfterHeavyScreen();
    super.dispose();
  }

  void _onZoomChanged(bool isZoomedIn) {
    if (isZoomedIn != _isZoomedIn) {
      setState(() => _isZoomedIn = isZoomedIn);
    }
  }

  void _onHoldChanged(bool isHoldingImage) {
    if (isHoldingImage != _isHoldingImage) {
      setState(() => _isHoldingImage = isHoldingImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ZoomableImagePage(
            imagePath: widget.imagePath,
            onZoomChanged: _onZoomChanged,
            onHoldChanged: _onHoldChanged,
          ),
          if (!_isZoomedIn && !_isHoldingImage)
            Positioned(
              top: topPadding + 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableImagePage extends StatefulWidget {
  const _ZoomableImagePage({
    required this.imagePath,
    required this.onZoomChanged,
    this.onHoldChanged,
  });

  final String imagePath;
  final ValueChanged<bool> onZoomChanged;
  final ValueChanged<bool>? onHoldChanged;

  @override
  State<_ZoomableImagePage> createState() => _ZoomableImagePageState();
}

class _ZoomableImagePageState extends State<_ZoomableImagePage> {
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomedIn = scale > 1.01;

    if (isZoomedIn != _isZoomedIn) {
      setState(() => _isZoomedIn = isZoomedIn);
      widget.onZoomChanged(isZoomedIn);
    }

    if (!isZoomedIn && _transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 1.01) {
      _transformationController.value = Matrix4.identity();
      if (_isZoomedIn) {
        setState(() => _isZoomedIn = false);
        widget.onZoomChanged(false);
      }
    }
  }

  void _toggleZoom() {
    if (_isZoomedIn) {
      _transformationController.value = Matrix4.identity();
      setState(() => _isZoomedIn = false);
      widget.onZoomChanged(false);
      return;
    }

    const scale = 2.4;
    final tapPosition = _doubleTapDetails?.localPosition;

    if (tapPosition == null) {
      _transformationController.value = Matrix4.diagonal3Values(
        scale,
        scale,
        1,
      );
    } else {
      _transformationController.value = Matrix4.identity()
        ..translate(
          -tapPosition.dx * (scale - 1),
          -tapPosition.dy * (scale - 1),
        )
        ..scale(scale);
    }

    setState(() => _isZoomedIn = true);
    widget.onZoomChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = AppImageCache.decodeCacheWidthForBoxWithDpr(
      width: viewport.width,
      height: viewport.height,
      devicePixelRatio: devicePixelRatio,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _toggleZoom,
      onLongPressStart: (_) => widget.onHoldChanged?.call(true),
      onLongPressEnd: (_) => widget.onHoldChanged?.call(false),
      onLongPressCancel: () => widget.onHoldChanged?.call(false),
      child: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1,
          maxScale: 4,
          panEnabled: _isZoomedIn,
          scaleEnabled: true,
          boundaryMargin: _isZoomedIn
              ? const EdgeInsets.all(80)
              : EdgeInsets.zero,
          onInteractionEnd: _onInteractionEnd,
          child: Image.file(
            File(widget.imagePath),
            width: viewport.width,
            height: viewport.height,
            fit: BoxFit.contain,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
