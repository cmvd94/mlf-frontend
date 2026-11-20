class AppConstants {
  static const String baseUrl = 'http://localhost:3500';
  static const Duration requestTimeout = Duration(seconds: 60);
  static const String tokenKey = 'mlf_auth_token';
  static const String userKey = 'mlf_user_data';

  // Tax / Financial Configuration Constants
  static const double defaultGstPercentage = 18.0;
  static const List<double> availableGstPercentages = [0.0, 5.0, 12.0, 18.0, 28.0];
}
