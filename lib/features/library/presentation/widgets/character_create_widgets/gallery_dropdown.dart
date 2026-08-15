import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';

class GalleryDropdown extends StatefulWidget {
  const GalleryDropdown({
    super.key,
    required this.imagePaths,
    required this.onChanged,
    required this.fileStorage,
    this.onCompressionStateChanged,
  });

  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;
  final LocalFileStorage fileStorage;
  final void Function(bool isCompressing, {int completed, int total})?
  onCompressionStateChanged;

  @override
  State<GalleryDropdown> createState() => _GalleryDropdownState();
}

class _GalleryDropdownState extends State<GalleryDropdown> {
  static const initialSlotCount = 5;
  static const _slotWidth = 90.0;
  static const _slotHeight = 120.0;
  static const _compressionBatchSize = 4;
  static const _thumbnailCacheWidth = 180;

  bool isExpanded = false;
  bool isCompressing = false;
  final scrollController = ScrollController();

  Future<void> pickImages() async {
    if (isCompressing) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    FocusManager.instance.primaryFocus?.unfocus();

    if (images.isEmpty || !mounted) {
      return;
    }

    final total = images.length;
    setState(() {
      isExpanded = true;
      isCompressing = true;
    });
    widget.onCompressionStateChanged?.call(
      true,
      completed: 0,
      total: total,
    );

    try {
      final stagedPaths = await _compressImages(images);
      if (!mounted) {
        return;
      }

      widget.onChanged([
        ...widget.imagePaths,
        ...stagedPaths,
      ]);
    } finally {
      if (mounted) {
        setState(() => isCompressing = false);
        widget.onCompressionStateChanged?.call(false);
      }
    }
  }

  Future<List<String>> _compressImages(List<XFile> images) async {
    final stagedPaths = <String>[];

    for (var start = 0; start < images.length; start += _compressionBatchSize) {
      final end = start + _compressionBatchSize;
      final batch = images.sublist(
        start,
        end > images.length ? images.length : end,
      );
      final batchPaths = await Future.wait(
        batch.map(
          (image) => widget.fileStorage.compressAndStagePickedFile(image.path),
        ),
      );
      stagedPaths.addAll(batchPaths);

      if (!mounted) {
        return stagedPaths;
      }

      widget.onCompressionStateChanged?.call(
        true,
        completed: stagedPaths.length,
        total: images.length,
      );
    }

    return stagedPaths;
  }

  Future<void> removeImage(int index) async {
    final removedPath = widget.imagePaths[index];
    final updatedPaths = [...widget.imagePaths];
    updatedPaths.removeAt(index);
    widget.onChanged(updatedPaths);
    AppImageCache.evictFile(removedPath);
    await widget.fileStorage.deleteDraftFile(removedPath);
  }

  void moveImage(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) {
      return;
    }

    final updatedPaths = [...widget.imagePaths];
    final movedPath = updatedPaths.removeAt(fromIndex);
    updatedPaths.insert(toIndex, movedPath);
    widget.onChanged(updatedPaths);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget buildImageSlot(int index) {
    final imagePath = widget.imagePaths[index];
    final slot = _buildImageSlot(index, imagePath);

    return DragTarget<int>(
      onAcceptWithDetails: (details) => moveImage(details.data, index),
      builder: (context, candidateData, rejectedData) {
        final highlightedSlot = candidateData.isEmpty
            ? slot
            : DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: slot,
              );

        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: _slotWidth,
              height: _slotHeight,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                cacheWidth: _thumbnailCacheWidth,
                gaplessPlayback: true,
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: highlightedSlot),
          child: highlightedSlot,
        );
      },
    );
  }

  Widget _buildImageSlot(int index, String imagePath) {
    final cacheWidth = AppImageCache.decodeCacheWidthForBox(
      width: _slotWidth,
      height: _slotHeight,
      context: context,
    );

    return Container(
      width: _slotWidth,
      height: _slotHeight,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              cacheWidth: cacheWidth,
              gaplessPlayback: true,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => removeImage(index),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: isCompressing ? null : pickImages,
      child: Container(
        width: 90,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: isCompressing
            ? const Center(
                child: Icon(Icons.hourglass_top, size: 36),
              )
            : const Stack(
          children: [
            Center(child: Icon(Icons.image_outlined, size: 50)),
            Positioned(
              right: 5,
              bottom: 5,
              child: Icon(Icons.add_circle_outline, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  int get _slotCount {
    if (widget.imagePaths.length < initialSlotCount) {
      return initialSlotCount;
    }

    return widget.imagePaths.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),

      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Gallery',

                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'GrenzeGotisch',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)
            SizedBox(
              height: 140,

              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.all(12),

                itemCount: _slotCount,

                itemBuilder: (context, index) {
                  return index >= widget.imagePaths.length
                      ? _buildAddButton()
                      : buildImageSlot(index);
                },
              ),
            ),
        ],
      ),
    );
  }
}
