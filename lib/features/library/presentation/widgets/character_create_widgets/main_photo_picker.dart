import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainPhotoPicker extends StatefulWidget {

  const MainPhotoPicker({
    super.key,
  });

  @override
  State<MainPhotoPicker>
  createState() =>
      _MainPhotoPickerState();
}

class _MainPhotoPickerState extends State<MainPhotoPicker> {

  File? imageFile;

  Future<void> pickImage()
  async {

    final picker = ImagePicker();

    final image =
    await picker.pickImage(
      source:
      ImageSource.gallery,
    );

    if (
    image != null
    ) {

      setState(() {

        imageFile =
            File(
              image.path,
            );
      });
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [

        GestureDetector(
          onTap: pickImage,

          child: Container(
            width: 150,
            height: 190,

            decoration:
            BoxDecoration(
              border:
              Border.all(
                color: Colors.black,
                width: 3,
              ),
            ),

            child: Stack(
              children: [

                Positioned.fill(
                  child:
                  imageFile == null

                      ? const Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: Colors.black,
                  )

                      : ClipRect(
                    child:
                    Image.file(
                      imageFile!,

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

                    decoration:
                    BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,

                      border:
                      Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),

                    child:
                    const Icon(
                      Icons.add,
                      size: 40,
                      color: Colors.black,
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

          style:
          TextStyle(
            fontSize: 30,
            color: Colors.black,
            fontFamily: 'JosefinSlab',
          ),
        ),
      ],
    );
  }
}