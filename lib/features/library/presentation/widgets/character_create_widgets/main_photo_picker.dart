import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/widgets/character/main_photo_crop_page.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';

class MainPhotoPicker extends StatefulWidget {
  const MainPhotoPicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
    required this.fileStorage,
  });

  final String? imagePath;
  final ValueChanged<String?> onChanged;
  final LocalFileStorage fileStorage;

  @override
  State<MainPhotoPicker> createState() => _MainPhotoPickerState();
}

class _MainPhotoPickerState extends State<MainPhotoPicker> {
  static const _previewWidth = 150.0;
  static const _previewHeight = 190.0;
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null || !mounted) {
      return;
    }

    await _openCrop(image.path);
  }

  Future<void> adjustCrop() async {
    final imagePath = widget.imagePath;
    if (imagePath == null || !mounted) {
      return;
    }

    await _openCrop(imagePath);
  }

  Future<void> _openCrop(String imagePath) async {
    final croppedPath = await MainPhotoCropPage.open(context, imagePath);
    if (croppedPath != null && mounted) {
      final previousPath = widget.imagePath;
      widget.onChanged(croppedPath);
      if (previousPath != null && previousPath != croppedPath) {
        AppImageCache.evictFile(previousPath);
        await widget.fileStorage.deleteDraftFile(previousPath);
      }
    }
  }

  Future<void> _removeImage() async {
    final previousPath = widget.imagePath;
    widget.onChanged(null);
    AppImageCache.evictFile(previousPath);
    await widget.fileStorage.deleteDraftFile(previousPath);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            width: _previewWidth,
            height: _previewHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 3),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.imagePath == null
                      ? const Icon(
                          Icons.image_outlined,
                          size: 100,
                          color: Colors.black,
                        )
                      : Image.file(
                          File(widget.imagePath!),
                          fit: BoxFit.contain,
                          cacheWidth: AppImageCache.decodeCacheWidthForBox(
                            width: _previewWidth,
                            height: _previewHeight,
                            context: context,
                          ),
                          gaplessPlayback: true,
                        ),
                ),
                if (widget.imagePath != null)
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: adjustCrop,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.crop,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: widget.imagePath == null ? 8 : 4,
                  bottom: widget.imagePath == null ? 8 : null,
                  top: widget.imagePath == null ? null : 4,
                  child: GestureDetector(
                    onTap: widget.imagePath == null
                        ? pickImage
                        : _removeImage,
                    child: Container(
                      width: widget.imagePath == null ? 34 : 28,
                      height: widget.imagePath == null ? 34 : 28,
                      decoration: BoxDecoration(
                        color: widget.imagePath == null
                            ? Colors.transparent
                            : Colors.black38,
                        shape: BoxShape.circle,
                        border: widget.imagePath == null
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: Icon(
                        widget.imagePath == null ? Icons.add : Icons.close,
                        size: widget.imagePath == null ? 28 : 20,
                        color: widget.imagePath == null
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add main photo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
            fontFamily: 'JosefinSlab',
          ),
        ),
      ],
    );
  }
}
