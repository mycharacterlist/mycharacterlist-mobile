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

  final ImagePicker _picker = ImagePicker();

  final List<File> _images = [];

  Future<void> _pickImage() async {

    final XFile? image =
    await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _images.add(
        File(image.path),
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
                onTap: _pickImage,

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

        const SizedBox(
          height: 90,
        ),
      ],
    );
  }
}