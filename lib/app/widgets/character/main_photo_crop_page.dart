import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/core/utils/image_compressor.dart';

class MainPhotoCropPage extends StatefulWidget {
  const MainPhotoCropPage({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  static Future<String?> open(BuildContext context, String imagePath) async {
    final rawBytes = await File(imagePath).readAsBytes();
    final imageBytes = const ImageCompressor().prepareForCrop(rawBytes);
    if (!context.mounted) {
      return null;
    }

    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MainPhotoCropPage(imageBytes: imageBytes),
      ),
    );
  }

  @override
  State<MainPhotoCropPage> createState() => _MainPhotoCropPageState();
}

class _MainPhotoCropPageState extends State<MainPhotoCropPage> {
  final _cropController = CropController();
  bool _isCropping = false;
  bool _isFullImageCrop = false;

  Rect? _viewportImageRect;
  Rect? _savedCropRect;
  Rect? _lastCropRect;

  static const _initialCropInset = 0.1;

  Future<String> _saveCroppedImage(Uint8List bytes) async {
    final compressed = await const ImageCompressor().compress(
      bytes,
      sourcePath: 'crop.jpg',
    );
    final outputBytes = compressed.bytes.length < bytes.length
        ? compressed.bytes
        : bytes;
    final extension = compressed.bytes.length < bytes.length
        ? compressed.extension
        : '.jpg';

    return LocalFileStorage().saveBytes(
      outputBytes,
      folder: LocalFileStorage.draftsFolder,
      extension: extension,
      compress: false,
    );
  }

  void _applyCrop() {
    if (_isCropping) {
      return;
    }

    setState(() => _isCropping = true);
    _cropController.crop();
  }

  void _toggleFullImageCrop() {
    if (_isCropping || _viewportImageRect == null) {
      return;
    }

    if (_isFullImageCrop) {
      if (_savedCropRect != null) {
        _cropController.cropRect = _savedCropRect!;
      }
      setState(() => _isFullImageCrop = false);
      return;
    }

    _savedCropRect = _lastCropRect ?? _viewportImageRect;
    _cropController.cropRect = _viewportImageRect!;
    setState(() => _isFullImageCrop = true);
  }

  void _onCropMoved(Rect cropRect, Rect imageBasedRect) {
    _lastCropRect = cropRect;
  }

  @override
  void dispose() {
    AppImageCache.trimAfterHeavyScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Adjust photo',
          style: TextStyle(fontFamily: 'FrancoisOne'),
        ),
        leading: IconButton(
          onPressed: _isCropping ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
        actions: [
          TextButton(
            onPressed: _isCropping ? null : _applyCrop,
            child: _isCropping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            bottom: 28 + bottomInset,
            child: GestureDetector(
              onDoubleTap: _toggleFullImageCrop,
              child: Crop(
                image: widget.imageBytes,
                controller: _cropController,
                interactive: true,
                fixCropRect: false,
                initialRectBuilder: InitialRectBuilder.withBuilder(
                  (viewportRect, imageRect) {
                    _viewportImageRect = imageRect;
                    return Rect.fromLTRB(
                      imageRect.left + imageRect.width * _initialCropInset,
                      imageRect.top + imageRect.height * _initialCropInset,
                      imageRect.right - imageRect.width * _initialCropInset,
                      imageRect.bottom - imageRect.height * _initialCropInset,
                    );
                  },
                ),
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.55),
                radius: 0,
                filterQuality: FilterQuality.high,
                clipBehavior: Clip.none,
                cornerDotBuilder: (size, edgeAlignment) =>
                    _CropCornerHandle(alignment: edgeAlignment),
                overlayBuilder: (context, rect) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                willUpdateScale: (newScale) => newScale >= 0.35 && newScale <= 8,
                onMoved: _onCropMoved,
                onCropped: (result) async {
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      try {
                        final path = await _saveCroppedImage(croppedImage);
                        if (mounted) {
                          Navigator.pop(context, path);
                        }
                      } catch (_) {
                        if (mounted) {
                          setState(() => _isCropping = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not save cropped photo.'),
                            ),
                          );
                        }
                      }
                    case CropFailure():
                      if (mounted) {
                        setState(() => _isCropping = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not crop photo.'),
                          ),
                        );
                      }
                  }
                },
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 6 + bottomInset,
            child: Text(
              'Pinch to zoom · drag corners · double tap for full image',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCornerHandle extends StatelessWidget {
  const _CropCornerHandle({required this.alignment});

  final EdgeAlignment alignment;

  @override
  Widget build(BuildContext context) {
    const armLength = 22.0;
    const thickness = 4.0;

    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _CornerHandlePainter(
          alignment: alignment,
          armLength: armLength,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _CornerHandlePainter extends CustomPainter {
  const _CornerHandlePainter({
    required this.alignment,
    required this.armLength,
    required this.thickness,
  });

  final EdgeAlignment alignment;
  final double armLength;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness + 2
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset origin, {required bool horizontalRight, required bool verticalDown}) {
      final horizontalEnd = origin.translate(
        horizontalRight ? armLength : -armLength,
        0,
      );
      final verticalEnd = origin.translate(
        0,
        verticalDown ? armLength : -armLength,
      );

      canvas.drawLine(origin, horizontalEnd, outline);
      canvas.drawLine(origin, verticalEnd, outline);
      canvas.drawLine(origin, horizontalEnd, fill);
      canvas.drawLine(origin, verticalEnd, fill);
    }

    switch (alignment) {
      case EdgeAlignment.topLeft:
        drawCorner(center, horizontalRight: true, verticalDown: true);
      case EdgeAlignment.topRight:
        drawCorner(center, horizontalRight: false, verticalDown: true);
      case EdgeAlignment.bottomLeft:
        drawCorner(center, horizontalRight: true, verticalDown: false);
      case EdgeAlignment.bottomRight:
        drawCorner(center, horizontalRight: false, verticalDown: false);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerHandlePainter oldDelegate) {
    return oldDelegate.alignment != alignment;
  }
}
