import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/gallery/data/repositories/gallery_repository_providers.dart';

final characterGalleryImagesProvider =
    FutureProvider.autoDispose.family<List<String>, String>((
  ref,
  characterId,
) {
  return ref.watch(galleryRepositoryProvider).getGalleryImagePaths(characterId);
});
