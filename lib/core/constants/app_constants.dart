class AppConstants {
  AppConstants._();

  static const String appName = 'LoyaltyLite Pro';
  static const String usersCollection = 'users';
  static const String customersSubcollection = 'customers';

  // Pagination defaults
  static const int defaultPageSize = 20;

  // Debounce durations
  static const Duration defaultDebounce = Duration(milliseconds: 300);
}
