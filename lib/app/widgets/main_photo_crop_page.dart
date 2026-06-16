import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/core/utils/image_compressor.dart';

class MainPhotoCropPage extends StatefulWidget {
  const MainPhotoCropPage({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  static const aspectRatio = 150 / 190;

  static Future<String?> open(BuildContext context, String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    if (!context.mounted) {
      return null;
    }

    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MainPhotoCropPage(imageBytes: bytes),
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
    return LocalFileStorage().saveBytes(
      compressed.bytes,
      folder: LocalFileStorage.draftsFolder,
      extension: compressed.extension,
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
              aspectRatio: MainPhotoCropPage.aspectRatio,
              interactive: true,
              fixCropRect: true,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.62),
              radius: 0,
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
              'Move and zoom the photo to choose the area for your avatar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
