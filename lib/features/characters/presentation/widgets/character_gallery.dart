import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterGallery extends StatelessWidget {
  const CharacterGallery({
    super.key,
    required this.imagePaths,
  });

  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return CharacterSectionPanel(
      title: 'Gallery:',
      child: imagePaths.isEmpty
          ? const Text(
              'No gallery images',
              style: AppTypography.characterSectionEmpty,
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
