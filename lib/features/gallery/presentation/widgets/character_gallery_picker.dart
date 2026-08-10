import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CharacterGalleryPicker extends StatefulWidget {
  const CharacterGalleryPicker({
    super.key,
  });

  @override
  State<CharacterGalleryPicker> createState() =>
      _CharacterGalleryPickerState();
}

class _CharacterGalleryPickerState extends State<CharacterGalleryPicker> {

  final List<File> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();

    if (images.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _images.addAll(
        images.map((image) => File(image.path)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),

          itemCount: _images.length + 1,

          itemBuilder: (context, index) {

            if (index == _images.length) {

              return InkWell(
                onTap: _pickImages,

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

            return Image.file(
              _images[index],
              fit: BoxFit.cover,
            );
          },
        ),

      ],
    );
  }
}
