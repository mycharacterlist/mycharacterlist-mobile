import 'package:flutter/material.dart';

class CharacterGallery extends StatelessWidget {

  const CharacterGallery({
    super.key,
  });

  static const List<String>
  galleryImages = [
    'assets/images/LouiseTest.jpg',
    'assets/images/LouiseTest.jpg',
    'assets/images/LouiseTest.jpg',
    'assets/images/LouiseTest.jpg',
    'assets/images/LouiseTest.jpg',
    'assets/images/LouiseTest.jpg',
  ];

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration:
      const BoxDecoration(
        color: Color(0xFFECEBEB),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Gallery:',

            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 180,

            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryImages.length,

              separatorBuilder:
                  (
                  context,
                  index,
                  ) {

                return const SizedBox(width: 10);
              },

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                return Container(
                  width: 130,

                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                  ),

                  child: ClipRRect(
                    child: Image.asset(
                      galleryImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}