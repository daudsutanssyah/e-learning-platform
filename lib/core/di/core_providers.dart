import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/network_checker.dart';
import '../services/local_json_service.dart';

/// Provider untuk [LocalJsonService] sebagai dependency injection global.
///
/// Digunakan di seluruh aplikasi untuk membaca data JSON dari asset lokal.
final localJsonServiceProvider = Provider<LocalJsonService>((ref) {
  return LocalJsonService();
});

/// Provider untuk [NetworkChecker] sebagai dependency injection global.
///
/// Digunakan untuk memeriksa status koneksi internet sebelum melakukan
/// operasi yang memerlukan jaringan (seperti streaming video YouTube).
final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return const DartIoNetworkChecker();
});

/// Provider untuk single instance [SupabaseClient] sebagai dependency injection global.
///
/// Mengakses `Supabase.instance.client` yang telah diinisialisasi pada `main()`.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
