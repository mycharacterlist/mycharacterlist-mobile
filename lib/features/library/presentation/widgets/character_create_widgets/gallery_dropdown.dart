import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryDropdown extends StatefulWidget {

  const GalleryDropdown({
    super.key,
  });

  @override
  State<GalleryDropdown>
  createState() =>
      _GalleryDropdownState();
}

class _GalleryDropdownState extends State<GalleryDropdown> {

  bool isExpanded = false;

  final List<File?>
  images = List.generate(
    6,
        (_) => null,
  );

  Future<void> pickImage(
      int index,
      ) async {

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

        images[index] =
            File(
              image.path,
            );
      });
    }
  }

  Widget buildImageSlot(
      int index,
      ) {

    return GestureDetector(
      onTap: () {

        pickImage(
          index,
        );
      },

      child: Container(
        width: 90,
        height: 120,

        margin:
        const EdgeInsets.only(right: 12,),

        decoration:
        BoxDecoration(
          border:
          Border.all(
            color: Colors.black,
            width: 2,
          ),
        ),

        child: Stack(
          children: [

            Positioned.fill(
              child:
              images[index] ==
                  null

                  ? const Icon(
                Icons.image_outlined,
                size: 50,
              )

                  : Image.file(
                images[index]!,

                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              right: 5,
              bottom: 5,

              child: Container(
                width: 30,
                height: 30,

                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,

                  border:
                  Border.all(
                    color: Colors.black,
                  ),
                ),

                child:
                const Icon(
                  Icons.add,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      decoration:
      BoxDecoration(
        border:
        Border.all(
          color: Colors.black,
          width: 2,
        ),
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
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              child: Row(
                children: [

                  const Expanded(
                    child: Text(
                      'Gallery',

                      style:
                      TextStyle(
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

              child:
              ListView.builder(
                scrollDirection:
                Axis.horizontal,

                padding: const EdgeInsets.all(12),

                itemCount: 6,

                itemBuilder:
                    (
                    context,
                    index,
                    ) {

                  return buildImageSlot(index,);
                },
              ),
            ),
        ],
      ),
    );
  }
}