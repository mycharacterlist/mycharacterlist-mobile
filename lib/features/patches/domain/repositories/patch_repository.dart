import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch_entry.dart';

abstract interface class PatchRepository {
  Future<String> getSuggestedPatchLabel(String listId);

  Future<RankingListPatch> createPatchFromCurrentList(
    String listId, {
    required String label,
  });

  Future<List<RankingListPatch>> getPatchesForList(String listId);

  Future<RankingListPatch?> getPatchById(String patchId);

  Future<List<RankingListPatchEntry>> getPatchEntries(String patchId);

  Future<void> deletePatch(String patchId);

  Future<void> saveImportedPatch(
    RankingListPatch patch,
    List<RankingListPatchEntry> entries,
  );
}
