/// Konfigurasi kredensial Supabase dari compile-time environment variables
/// dengan fallback default agar aplikasi dapat langsung dijalankan (plug-and-play).
final class SupabaseConfig {
  const SupabaseConfig._();

  /// URL endpoint proyek Supabase.
  ///
  /// Disediakan saat build/run melalui `--dart-define=SUPABASE_URL=...`
  /// atau `--dart-define-from-file=env.json`. Jika tidak disediakan,
  /// menggunakan nilai default dari konfigurasi proyek.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ykpqdweoiwftmqbgkmep.supabase.co',
  );

  /// Kunci anonim publik (anon public key) Supabase.
  ///
  /// Disediakan saat build/run melalui `--dart-define=SUPABASE_ANON_KEY=...`
  /// atau `--dart-define-from-file=env.json`. Jika tidak disediakan,
  /// menggunakan nilai default dari konfigurasi proyek.
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_h-FynmaMLpDol4_qWNQFKg_2PTELeEh',
  );

  /// Memverifikasi apakah kredensial Supabase sudah terkonfigurasi secara lengkap.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
