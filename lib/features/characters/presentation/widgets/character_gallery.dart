import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';
import 'package:mycharacterlist/features/gallery/gallery_providers.dart';
import 'package:mycharacterlist/features/gallery/presentation/widgets/gallery_action_button.dart';

class CharacterGallery extends ConsumerWidget {
  const CharacterGallery({
    super.key,
    required this.characterId,
    required this.imagePaths,
  });

  final String characterId;
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CharacterSectionPanel(
      title: 'Gallery:',
      trailing: GestureDetector(
        onTap: () async {
          await context.push(AppRoutes.characterGalleryById(characterId));
          ref.invalidate(characterByIdProvider(characterId));
          ref.invalidate(characterGalleryImagesProvider(characterId));
        },
        child: const GalleryActionButton(),
      ),
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
                      previewImagePaths: imagePaths,
                      previewInitialIndex: index,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
