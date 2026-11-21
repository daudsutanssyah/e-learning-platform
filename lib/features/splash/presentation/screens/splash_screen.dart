import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../course/domain/entities/course_entity.dart';
import '../../../course/presentation/providers/course_providers.dart';
import '../../../progress/domain/entities/learning_progress_state.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

/// Layar Splash Screen interaktif dengan animasi Lottie dan background preloading data.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _textAnimController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Hapus native splash screen pada platform non-web begitu widget selesai di-mount
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FlutterNativeSplash.remove();
      });
    }

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _textAnimController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textAnimController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textAnimController.forward();

    // Mulai preloading data di background sambil menampilkan animasi Lottie
    _preloadDataAndNavigate();
  }

  Future<void> _preloadDataAndNavigate() async {
    // Berikan durasi minimum 1400 ms agar animasi Lottie dan teks branding
    // dapat dinikmati pengguna secara elegan tanpa perpindahan kasar/loncat
    final minDisplayDuration =
        Future.delayed(const Duration(milliseconds: 1400));

    // Preload daftar kursus dari Supabase & status progres dari SharedPreferences
    final preloadFuture = Future.wait([
      ref
          .read(coursesListProvider.future)
          .catchError((_) => <CourseEntity>[]),
      ref
          .read(progressNotifierProvider.future)
          .catchError((_) => const LearningProgressState()),
    ]).timeout(
      const Duration(milliseconds: 3500),
      onTimeout: () => [],
    );

    // Tunggu kedua proses (durasi minimum branding + preload data) selesai
    await Future.wait([preloadFuture, minDisplayDuration]);

    if (!mounted) return;
    context.go(AppRoutes.courseListPath);
  }

  @override
  void dispose() {
    _textAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animasi Lottie Edukasi
                  SizedBox(
                    height: size.height * 0.38,
                    child: Lottie.asset(
                      AppAssets.splashAnimation,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Teks Animasi Branding
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Judul Aplikasi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'EduPlatform',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Slogan / Tagline
                          const Text(
                            'Belajar Kapan Saja, Di Mana Saja',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
