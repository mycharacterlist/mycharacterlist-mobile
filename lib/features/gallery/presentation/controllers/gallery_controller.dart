import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';

class GalleryController {
  GalleryController(this.characterId);

  final String characterId;

  void openGallery(BuildContext context) {
    context.push(AppRoutes.characterGalleryById(characterId));
  }
}

final galleryControllerProvider =
    Provider.autoDispose.family<GalleryController, String>(
  (ref, characterId) => GalleryController(characterId),
);
