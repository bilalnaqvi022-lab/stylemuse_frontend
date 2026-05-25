class ApiConfig {
  // ── YOUR RAILWAY URL goes here after deployment ──
  // Example: https://stylemuse-backend-production.up.railway.app
  static const String baseUrl = 'https://web-mongodburi-c300.up.railway.app';

  // For local testing before Railway deployment:
  // static const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000'; // Chrome/iOS

  static const String apiBase = '$baseUrl/api';

  // Auth
  static const String register = '$apiBase/auth/register';
  static const String login    = '$apiBase/auth/login';
  static const String me       = '$apiBase/auth/me';
  static const String profile  = '$apiBase/auth/profile';

  // Outfits
  static const String outfits         = '$apiBase/outfits';
  static const String trendingOutfits = '$apiBase/outfits/trending';
  static const String savedOutfits    = '$apiBase/outfits/saved';
  static String saveOutfit(String id)   => '$apiBase/outfits/saved/$id';
  static String outfitById(String id)   => '$apiBase/outfits/$id';

  // Closet
  static const String closet = '$apiBase/closet';
  static String closetItem(String id) => '$apiBase/closet/$id';
  static String logWear(String id)    => '$apiBase/closet/$id/wear';

  // Upload
  static const String uploadImage = '$apiBase/upload/image';

  // Calendar
  static const String calendar = '$apiBase/calendar';
  static String calendarDate(String date) => '$apiBase/calendar/$date';

  // AI
  static const String aiGenerate = '$apiBase/ai/generate';

  // Stats
  static const String stats = '$apiBase/stats';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 40);
}
