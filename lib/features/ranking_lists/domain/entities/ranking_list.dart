class RankingList {
  const RankingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.showAvatars = false,
  });

  final String id;
  final String name;
  final String description;
  final bool showAvatars;
  final DateTime createdAt;
  final DateTime updatedAt;

  RankingList copyWith({
    String? id,
    String? name,
    String? description,
    bool? showAvatars,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RankingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      showAvatars: showAvatars ?? this.showAvatars,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
