import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/course/presentation/screens/course_detail_screen.dart';
import '../../features/course/presentation/screens/course_list_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/video_player/presentation/screens/lesson_player_screen.dart';
import 'app_routes.dart';

/// Provider konfigurasi global [GoRouter] untuk navigasi deklaratif aplikasi.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.courseListPath,
        name: AppRoutes.courseListName,
        builder: (context, state) => const CourseListScreen(),
      ),
      GoRoute(
        path: AppRoutes.courseDetailPath,
        name: AppRoutes.courseDetailName,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: AppRoutes.lessonPlayerPath,
        name: AppRoutes.lessonPlayerName,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return LessonPlayerScreen(
            courseId: courseId,
            initialLessonId: lessonId,
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Halaman Tidak Ditemukan'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.explore_off_rounded,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Halaman "${state.uri}" tidak ditemukan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.courseListPath),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
});
