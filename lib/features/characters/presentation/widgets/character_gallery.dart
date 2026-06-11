import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterGallery extends StatelessWidget {
  const CharacterGallery({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
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
          if (imagePaths.isEmpty)
            const Text(
              'No gallery images',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontFamily: 'Joan',
              ),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 130,
                    height: 180,
                    child: CharacterImage(
                      imagePath: imagePaths[index],
                      width: 130,
                      height: 180,
                      placeholderIconSize: 48,
                      enableFullscreenPreview: true,
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
