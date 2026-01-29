/// App route names for navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String permission = '/permission';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // Existing routes - keeping for backward compatibility if needed during migration
  static const String home = '/home'; // Will likely be replaced by dashboard
  static const String tracking = '/tracking';
  static const String summary = '/summary';

  // New routes for redesigned UI
  static const String hikeCompletion = '/hike-completion';
  static const String addHikeDetails = '/add-hike-details';
  static const String hikesList = '/hikes-list';
  static const String hikeDetails = '/hike-details';
}
