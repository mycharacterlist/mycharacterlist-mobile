class CharacterExportResult {
  const CharacterExportResult({
    required this.directoryPath,
    required this.characters,
    required this.lists,
    required this.images,
    required this.missingImages,
  });

  final String directoryPath;
  final int characters;
  final int lists;
  final int images;
  final int missingImages;

  String get message =>
      'Exported: $characters characters, $lists lists, $images images, '
      'missing images: $missingImages. Saved to: $directoryPath';
}
