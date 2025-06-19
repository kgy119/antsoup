class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String settings = '/settings';

  // Route parameters
  static const String chatIdParam = 'chatId';
  static const String userIdParam = 'userId';

  // Route with parameters
  static String chatWithId(String chatId) => '/chat?$chatIdParam=$chatId';
  static String profileWithId(String userId) => '/profile?$userIdParam=$userId';
}