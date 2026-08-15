import 'package:flutter/material.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterGalleryPicker extends StatefulWidget {
  const CharacterGalleryPicker({
    super.key,
    required this.characterId,
    required this.imagePaths,
    required this.onAddPressed,
    required this.onRemoveImage,
    required this.onReorderImage,
    this.isSaving = false,
    this.isEditMode = false,
  });

  final String characterId;
  final List<String> imagePaths;
  final VoidCallback onAddPressed;
  final ValueChanged<int> onRemoveImage;
  final void Function(int fromIndex, int toIndex) onReorderImage;
  final bool isSaving;
  final bool isEditMode;

  @override
  State<CharacterGalleryPicker> createState() =>
      _CharacterGalleryPickerState();
}

class _CharacterGalleryPickerState extends State<CharacterGalleryPicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),

          itemCount: widget.imagePaths.length + 1,

          itemBuilder: (context, index) {
            if (index == widget.imagePaths.length) {
              return InkWell(
                onTap: widget.isSaving ? null : widget.onAddPressed,

                borderRadius: BorderRadius.circular(12),

                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,

                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 60,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }

            final imageTile = _GalleryImageTile(
              key: ValueKey(widget.imagePaths[index]),
              characterId: widget.characterId,
              imagePaths: widget.imagePaths,
              index: index,
              isEditMode: widget.isEditMode,
              isSaving: widget.isSaving,
              onRemoveImage: widget.onRemoveImage,
            );

            if (!widget.isEditMode || widget.isSaving) {
              return imageTile;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                return DragTarget<int>(
                  onAcceptWithDetails: (details) {
                    widget.onReorderImage(details.data, index);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHighlighted = candidateData.isNotEmpty;
                    final highlightedTile = DecoratedBox(
                      decoration: BoxDecoration(
                        border: isHighlighted
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                      child: imageTile,
                    );

                    return LongPressDraggable<int>(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Opacity(
                            opacity: 0.88,
                            child: _GalleryImageTile(
                              key: ValueKey(
                                'drag-${widget.imagePaths[index]}',
                              ),
                              characterId: widget.characterId,
                              imagePaths: widget.imagePaths,
                              index: index,
                              isEditMode: false,
                              isSaving: widget.isSaving,
                              onRemoveImage: widget.onRemoveImage,
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: highlightedTile,
                      ),
                      child: highlightedTile,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _GalleryImageTile extends StatelessWidget {
  const _GalleryImageTile({
    super.key,
    required this.characterId,
    required this.imagePaths,
    required this.index,
    required this.isEditMode,
    required this.isSaving,
    required this.onRemoveImage,
  });

  final String characterId;
  final List<String> imagePaths;
  final int index;
  final bool isEditMode;
  final bool isSaving;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isEditMode,
            child: CharacterImage(
              key: ValueKey(imagePaths[index]),
              imagePath: imagePaths[index],
              characterFolder: characterId,
              fit: BoxFit.cover,
              enableFullscreenPreview: true,
              previewImagePaths: imagePaths,
              previewInitialIndex: index,
            ),
          ),
        ),
        if (isEditMode)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ),
        if (isEditMode)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: isSaving ? null : () => onRemoveImage(index),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
