class CharacterImportResult {
  const CharacterImportResult({
    required this.created,
    required this.updated,
    required this.failed,
    this.listsCreated = 0,
    this.listsUpdated = 0,
    this.listsFailed = 0,
    this.missingListCharacters = 0,
    this.patchesCreated = 0,
    this.patchesUpdated = 0,
    this.patchesFailed = 0,
  });

  final int created;
  final int updated;
  final int failed;
  final int listsCreated;
  final int listsUpdated;
  final int listsFailed;
  final int missingListCharacters;
  final int patchesCreated;
  final int patchesUpdated;
  final int patchesFailed;

  String get message {
    final parts = [
      'Characters created: $created, updated: $updated, failed: $failed.',
    ];

    if (listsCreated > 0 || listsUpdated > 0 || listsFailed > 0) {
      parts.add(
        'Lists created: $listsCreated, updated: $listsUpdated, failed: $listsFailed.',
      );
    }

    if (missingListCharacters > 0) {
      parts.add('Missing characters in lists: $missingListCharacters.');
    }

    if (patchesCreated > 0 || patchesUpdated > 0 || patchesFailed > 0) {
      parts.add(
        'Patches created: $patchesCreated, updated: $patchesUpdated, failed: $patchesFailed.',
      );
    }

    return parts.join(' ');
  }
}
