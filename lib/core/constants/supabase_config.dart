final class SupabaseConfig {
  const SupabaseConfig._();

  /// URL endpoint proyek Supabase.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ykpqdweoiwftmqbgkmep.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_h-FynmaMLpDol4_qWNQFKg_2PTELeEh',
  );

  /// verifikasi apakah kredensial Supabase sudah terkonfigurasi secara lengkap.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
