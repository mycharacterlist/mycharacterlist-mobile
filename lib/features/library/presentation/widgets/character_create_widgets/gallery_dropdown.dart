import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryDropdown extends StatefulWidget {
  const GalleryDropdown({
    super.key,
    required this.imagePaths,
    required this.onChanged,
  });

  final List<String> imagePaths;
  final ValueChanged<List<String>> onChanged;

  @override
  State<GalleryDropdown> createState() => _GalleryDropdownState();
}

class _GalleryDropdownState extends State<GalleryDropdown> {
  static const initialSlotCount = 5;

  bool isExpanded = false;
  final scrollController = ScrollController();

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isEmpty) {
      return;
    }

    widget.onChanged([
      ...widget.imagePaths,
      ...images.map((image) => image.path),
    ]);
  }

  void removeImage(int index) {
    final updatedPaths = [...widget.imagePaths];
    updatedPaths.removeAt(index);
    widget.onChanged(updatedPaths);
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
              width: 90,
              height: 120,
              child: Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: highlightedSlot),
          child: highlightedSlot,
        );
      },
    );
  }

  Widget _buildImageSlot(int index, String imagePath) {
    return Container(
      width: 90,
      height: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(File(imagePath), fit: BoxFit.cover),
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
      onTap: pickImages,
      child: Container(
        width: 90,
        height: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: const Stack(
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
