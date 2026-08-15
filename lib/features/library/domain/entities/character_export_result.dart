class CharacterExportResult {
  const CharacterExportResult({
    required this.directoryPath,
    required this.characters,
    required this.lists,
    required this.patches,
    required this.images,
    required this.missingImages,
  });

  final String directoryPath;
  final int characters;
  final int lists;
  final int patches;
  final int images;
  final int missingImages;

  String get message {
    final parts = [
      'Exported: $characters characters, $lists lists',
      if (patches > 0) '$patches patches',
      '$images images, missing images: $missingImages. Saved to: $directoryPath',
    ];
    return parts.join(', ');
  }
}
