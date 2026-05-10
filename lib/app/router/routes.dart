class AppRoutes {
  const AppRoutes._();

  // App routes.
  static const home = '/';
  static const lists = '/lists';
  static const rankingList = '/lists/:id';
  static const character = '/characters/:id';
  static const characterCreate = '/characters/create';
  static const library = '/library';

  // Dev routes.
  static const dev = '/dev';
  static const homePreview = '/home-preview';

  // Route builders.
  static String rankingListById(String id) => '/lists/$id';
  static String characterById(String id) => '/characters/$id';
}
