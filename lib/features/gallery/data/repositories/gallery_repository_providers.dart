import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:mycharacterlist/features/gallery/domain/repositories/gallery_repository.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>(
  (ref) => GalleryRepositoryImpl(
    characterRepository: ref.watch(characterRepositoryProvider),
  ),
);
