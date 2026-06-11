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
                  right: widget.imagePath == null ? 8 : 4,
                  bottom: widget.imagePath == null ? 8 : null,
                  top: widget.imagePath == null ? null : 4,

                  child: GestureDetector(
                    onTap: widget.imagePath == null
                        ? pickImage
                        : () => widget.onChanged(null),
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
