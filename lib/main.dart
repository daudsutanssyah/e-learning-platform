import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  try {
    if (SupabaseConfig.isConfigured) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.anonKey,
      );
    } else {
      debugPrint(
        'PERINGATAN: SupabaseConfig belum terkonfigurasi secara lengkap.',
      );
    }
  } catch (error, stackTrace) {
    debugPrint(
      'Gagal menginisialisasi Supabase pada startup: $error\n$stackTrace',
    );
  }

  runApp(const ProviderScope(child: ELearningApp()));
}

class ELearningApp extends ConsumerStatefulWidget {
  const ELearningApp({super.key});

  @override
  ConsumerState<ELearningApp> createState() => _ELearningAppState();
}

class _ELearningAppState extends ConsumerState<ELearningApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Simple E-Learning Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
