class MigratedCharacterImages {
  const MigratedCharacterImages({
    this.mainImagePath,
    this.galleryImagePaths = const [],
  });

  final String? mainImagePath;
  final List<String> galleryImagePaths;
}
