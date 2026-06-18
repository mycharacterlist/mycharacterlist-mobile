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
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              interactive: true,
              fixCropRect: false,
              initialRectBuilder: InitialRectBuilder.withBuilder(
                (viewportRect, imageRect) => imageRect,
              ),
              baseColor: Colors.black,
              maskColor: Colors.black.withValues(alpha: 0.62),
              radius: 0,
              filterQuality: FilterQuality.high,
              cornerDotBuilder: (size, edgeAlignment) => DotControl(
                color: Colors.white,
              ),
              willUpdateScale: (newScale) => newScale <= 8,
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
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomInset),
            child: const Text(
              'Pinch to zoom. Drag corners to resize the crop area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
