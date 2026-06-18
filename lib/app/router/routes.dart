class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const lists = '/lists';
  static const rankingList = '/lists/:id';
  static const rankingListPatches = '/lists/:id/patches';
  static const rankingListPatch = '/lists/:id/patches/:patchId';
  static const character = '/characters/:id';
  static const characterCreate = '/characters/create';
  static const characterEdit = '/characters/:id/edit';
  static const library = '/library';

  static String rankingListById(String id) => '/lists/$id';
  static String rankingListPatchesById(String listId) => '/lists/$listId/patches';
  static String rankingListPatchById(String listId, String patchId) => '/lists/$listId/patches/$patchId';
  static String characterById(String id) => '/characters/$id';
  static String characterEditById(String id) => '/characters/$id/edit';
}
