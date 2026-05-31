import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';

class RankingListModel extends RankingList {
  const RankingListModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.showAvatars,
    super.colorValue,
  });

  factory RankingListModel.fromEntity(RankingList list) {
    return RankingListModel(
      id: list.id,
      name: list.name,
      description: list.description,
      showAvatars: list.showAvatars,
      colorValue: list.colorValue,
      createdAt: list.createdAt,
      updatedAt: list.updatedAt,
    );
  }

  factory RankingListModel.fromJson(Map<String, dynamic> json) {
    return RankingListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      showAvatars: json['showAvatars'] as bool? ?? false,
      colorValue: json['colorValue'] as int? ?? RankingList.defaultColorValue,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory RankingListModel.fromDatabase(Map<String, Object?> data) {
    return RankingListModel(
      id: data['id']! as String,
      name: data['name']! as String,
      description: data['description']! as String,
      showAvatars: (data['show_avatars']! as int) == 1,
      colorValue: data['color_value'] as int? ?? RankingList.defaultColorValue,
      createdAt: DateTime.parse(data['created_at']! as String),
      updatedAt: DateTime.parse(data['updated_at']! as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'showAvatars': showAvatars,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'show_avatars': showAvatars ? 1 : 0,
      'color_value': colorValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
