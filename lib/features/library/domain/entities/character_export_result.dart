class CharacterExportResult {
  const CharacterExportResult({
    required this.directoryPath,
    required this.characters,
    required this.images,
    required this.missingImages,
  });

  final String directoryPath;
  final int characters;
  final int images;
  final int missingImages;

  String get message =>
      'Exported: $characters characters, $images images, '
      'missing images: $missingImages.';
}
