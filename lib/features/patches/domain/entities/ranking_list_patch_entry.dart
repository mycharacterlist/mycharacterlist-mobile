class RankingListPatchEntry {
  const RankingListPatchEntry({
    required this.id,
    required this.patchId,
    required this.characterId,
    required this.characterName,
    required this.sourceTitle,
    required this.position,
  });

  final String id;
  final String patchId;
  final String characterId;
  final String characterName;
  final String sourceTitle;
  final int position;
}
