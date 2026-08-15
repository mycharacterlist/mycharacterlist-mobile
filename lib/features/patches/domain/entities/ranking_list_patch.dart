class RankingListPatch {
  const RankingListPatch({
    required this.id,
    required this.listId,
    required this.label,
    required this.createdAt,
  });

  final String id;
  final String listId;
  final String label;
  final DateTime createdAt;
}
