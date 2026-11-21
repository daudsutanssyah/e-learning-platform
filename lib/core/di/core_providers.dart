import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/network_checker.dart';

/// Provider untuk [NetworkChecker] sebagai dependency injection global.

final networkCheckerProvider = Provider<NetworkChecker>((ref) {
  return const DartIoNetworkChecker();
});

/// Provider untuk single instance [SupabaseClient] sebagai dependency injection global.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
