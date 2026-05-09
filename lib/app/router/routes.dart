class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const lists = '/lists';
  static const rankingList = '/lists/:id';
  static const character = '/characters/:id';
  static const characterCreate = '/characters/create';
  static const library = '/library';

  static String rankingListById(String id) => '/lists/$id';
  static String characterById(String id) => '/characters/$id';
}
