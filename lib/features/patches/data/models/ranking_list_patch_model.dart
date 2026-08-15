import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';

class RankingListPatchModel extends RankingListPatch {
  const RankingListPatchModel({
    required super.id,
    required super.listId,
    required super.label,
    required super.createdAt,
  });

  factory RankingListPatchModel.fromEntity(RankingListPatch patch) {
    return RankingListPatchModel(
      id: patch.id,
      listId: patch.listId,
      label: patch.label,
      createdAt: patch.createdAt,
    );
  }

  factory RankingListPatchModel.fromJson(Map<String, dynamic> json) {
    return RankingListPatchModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      label: json['label'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory RankingListPatchModel.fromDatabase(Map<String, Object?> data) {
    return RankingListPatchModel(
      id: data['id']! as String,
      listId: data['list_id']! as String,
      label: data['label']! as String,
      createdAt: DateTime.parse(data['created_at']! as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'list_id': listId,
      'label': label,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
