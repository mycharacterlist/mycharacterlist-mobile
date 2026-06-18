import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch.dart';

class RankingListPatchModel extends RankingListPatch {
  const RankingListPatchModel({
    required super.id,
    required super.listId,
    required super.label,
    required super.createdAt,
  });

  factory RankingListPatchModel.fromDatabase(Map<String, Object?> data) {
    return RankingListPatchModel(
      id: data['id']! as String,
      listId: data['list_id']! as String,
      label: data['label']! as String,
      createdAt: DateTime.parse(data['created_at']! as String),
    );
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
