class SupabaseConfig {
  static const String url = 'https://krjqwfveguchkopdynbn.supabase.co';
  static const String anonKey =
      'sb_publishable_sHHnv-ju_7eBPhvZgCnwsQ_sr3L7-UT';
}

class MapsConfig {}

class AppConfig {
  static const String emailDomain = '@lus.ac.bd';
  static const int rideExpiryMinutes = 30;
  static const int cooldownMinutes = 30;
  static const int otpLength = 8;
  static const int splashMinMillis = 1200;
  static const int leaderboardLimit = 50;
  static const int latestRidesLimit = 10;
  static const int pointsPerBookedRide = 10;

  static final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@lus\.ac\.bd$');
}