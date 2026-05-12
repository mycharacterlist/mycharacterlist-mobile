class RankedCharacter {
  const RankedCharacter({
    required this.id,
    required this.listId,
    required this.characterId,
    required this.position,
    required this.addedAt,
  });

  final String id;
  final String listId;
  final String characterId;
  final int position;
  final DateTime addedAt;

  RankedCharacter copyWith({
    String? id,
    String? listId,
    String? characterId,
    int? position,
    DateTime? addedAt,
  }) {
    return RankedCharacter(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      characterId: characterId ?? this.characterId,
      position: position ?? this.position,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
