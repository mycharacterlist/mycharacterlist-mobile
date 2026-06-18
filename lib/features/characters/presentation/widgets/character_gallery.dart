import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterGallery extends StatelessWidget {
  const CharacterGallery({
    super.key,
    required this.characterId,
    required this.imagePaths,
  });

  final String characterId;
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return CharacterSectionPanel(
      title: 'Gallery:',
      child: imagePaths.isEmpty
          ? SizedBox(
              height: 180,
              child: Align(
                alignment: Alignment.centerLeft,
                child: CharacterImage(
                  imagePath: null,
                  characterFolder: characterId,
                  width: 130,
                  height: 180,
                  placeholderIconSize: 48,
                  showPlaceholderBorder: true,
                ),
              ),
            )
          : SizedBox(
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
                      characterFolder: characterId,
                      width: 130,
                      height: 180,
                      placeholderIconSize: 48,
                      enableFullscreenPreview: true,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
