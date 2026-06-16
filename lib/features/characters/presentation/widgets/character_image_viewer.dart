import 'dart:io';

import 'package:flutter/material.dart';

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
}

class _FullScreenImageViewer extends StatefulWidget {
  const _FullScreenImageViewer({required this.imagePath});

  final String imagePath;

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final _transformationController = TransformationController();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
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
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
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
