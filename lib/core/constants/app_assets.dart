/// Konstanta path aset aplikasi.
///
/// Menyimpan semua path ke file asset untuk akses yang konsisten
/// dan menghindari typo string literal.
final class AppAssets {
  const AppAssets._();

  /// Path ke file JSON mock data courses.
  static const String coursesMockJson = 'assets/mock_data/courses_response.json';

  /// Path ke file animasi Lottie untuk splash screen.
  static const String splashAnimation = 'assets/animations/education_splash.json';

  /// Path ke gambar logo splash.
  static const String splashLogo = 'assets/images/splash_logo.png';
}
