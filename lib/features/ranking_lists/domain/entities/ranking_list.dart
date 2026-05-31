class RankingList {
  static const defaultColorValue = 0xFF768AFD;

  const RankingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.showAvatars = false,
    this.colorValue = defaultColorValue,
  });

  final String id;
  final String name;
  final String description;
  final bool showAvatars;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;

  RankingList copyWith({
    String? id,
    String? name,
    String? description,
    bool? showAvatars,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RankingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      showAvatars: showAvatars ?? this.showAvatars,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
