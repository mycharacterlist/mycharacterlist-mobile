enum CharacterImportPhase {
  characters,
  lists,
  exportCharacters,
  exportLists,
}

class CharacterImportProgress {
  const CharacterImportProgress({
    required this.completed,
    required this.total,
    required this.phase,
  });

  final int completed;
  final int total;
  final CharacterImportPhase phase;

  String get title {
    return switch (phase) {
      CharacterImportPhase.characters => 'Importing characters...',
      CharacterImportPhase.lists => 'Importing lists...',
      CharacterImportPhase.exportCharacters => 'Exporting characters...',
      CharacterImportPhase.exportLists => 'Exporting lists...',
    };
  }
}
