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
    this.listOrder = 0,
  });

  final String id;
  final String name;
  final String description;
  final bool showAvatars;
  final int colorValue;
  final int listOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  RankingList copyWith({
    String? id,
    String? name,
    String? description,
    bool? showAvatars,
    int? colorValue,
    int? listOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RankingList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      showAvatars: showAvatars ?? this.showAvatars,
      colorValue: colorValue ?? this.colorValue,
      listOrder: listOrder ?? this.listOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
