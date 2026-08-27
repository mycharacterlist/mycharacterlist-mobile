import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CompareCharacterPicker extends StatefulWidget {
  const CompareCharacterPicker({
    super.key,
  });

  @override
  State<CompareCharacterPicker> createState() =>
      _CompareCharacterPickerState();
}

class _CompareCharacterPickerState
    extends State<CompareCharacterPicker> {

  final ImagePicker _picker = ImagePicker();

  File? _image;

  Future<void> _pickImage() async {
    final XFile? image =
    await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,

      child: AspectRatio(
        aspectRatio: 0.75,

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,

            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),

          child: _image == null
              ? const Center(
            child: Icon(
              Icons.add,
              size: 60,
              color: Colors.black,
            ),
          )
              : Image.file(
            _image!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}