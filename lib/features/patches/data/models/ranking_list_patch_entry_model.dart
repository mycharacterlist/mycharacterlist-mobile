import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch_entry.dart';

class RankingListPatchEntryModel extends RankingListPatchEntry {
  const RankingListPatchEntryModel({
    required super.id,
    required super.patchId,
    required super.characterId,
    required super.characterName,
    required super.sourceTitle,
    required super.position,
  });

  factory RankingListPatchEntryModel.fromDatabase(Map<String, Object?> data) {
    return RankingListPatchEntryModel(
      id: data['id']! as String,
      patchId: data['patch_id']! as String,
      characterId: data['character_id']! as String,
      characterName: data['character_name']! as String,
      sourceTitle: data['source_title']! as String,
      position: data['position']! as int,
    );
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'patch_id': patchId,
      'character_id': characterId,
      'character_name': characterName,
      'source_title': sourceTitle,
      'position': position,
    };
  }
}
