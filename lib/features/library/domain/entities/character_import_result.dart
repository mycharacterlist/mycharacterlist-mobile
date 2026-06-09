class CharacterImportResult {
  const CharacterImportResult({
    required this.created,
    required this.updated,
    required this.failed,
  });

  final int created;
  final int updated;
  final int failed;

  String get message =>
      'Created: $created, updated: $updated, failed: $failed.';
}
