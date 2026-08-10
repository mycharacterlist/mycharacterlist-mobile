import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterGalleryPicker extends StatefulWidget {
  const CharacterGalleryPicker({
    super.key,
    required this.characterId,
    required this.imagePaths,
    required this.onAddImages,
    this.isSaving = false,
  });

  final String characterId;
  final List<String> imagePaths;
  final Future<void> Function(List<String> imagePaths) onAddImages;
  final bool isSaving;

  @override
  State<CharacterGalleryPicker> createState() =>
      _CharacterGalleryPickerState();
}

class _CharacterGalleryPickerState extends State<CharacterGalleryPicker> {
  Future<void> _pickImages() async {
    if (widget.isSaving) {
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isEmpty || !mounted) {
      return;
    }

    await widget.onAddImages(
      images.map((image) => image.path).toList(),
    );
  }

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
                onTap: widget.isSaving ? null : _pickImages,

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

            return CharacterImage(
              imagePath: widget.imagePaths[index],
              characterFolder: widget.characterId,
              fit: BoxFit.cover,
              enableFullscreenPreview: true,
            );
          },
        ),
      ],
    );
  }
}
