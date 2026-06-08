import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainPhotoPicker extends StatefulWidget {
  const MainPhotoPicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
  });

  final String? imagePath;
  final ValueChanged<String?> onChanged;

  @override
  State<MainPhotoPicker> createState() => _MainPhotoPickerState();
}

class _MainPhotoPickerState extends State<MainPhotoPicker> {
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onChanged(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        GestureDetector(
          onTap: pickImage,
          onLongPress: widget.imagePath == null
              ? null
              : () => widget.onChanged(null),

          child: Container(
            width: 150,
            height: 190,

            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 3),
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
                      : ClipRect(
                          child: Image.file(
                            File(widget.imagePath!),

                            fit: BoxFit.cover,
                          ),
                        ),
                ),

                Positioned(
                  right: 8,
                  bottom: 8,

                  child: Container(
                    width: 50,
                    height: 50,

                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,

                      border: Border.all(color: Colors.black, width: 2),
                    ),

                    child: const Icon(Icons.add, size: 40, color: Colors.black),
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
