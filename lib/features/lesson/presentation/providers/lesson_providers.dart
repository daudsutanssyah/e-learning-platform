import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/data_sources/lesson_data_source.dart';
import '../../data/data_sources/supabase_lesson_data_source.dart';
import '../../data/repositories/lesson_repository_impl.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/usecases/get_lesson_by_id_usecase.dart';
import '../../domain/usecases/get_lessons_by_course_id_usecase.dart';



final lessonDataSourceProvider = Provider<LessonDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final networkChecker = ref.watch(networkCheckerProvider);
  return SupabaseLessonDataSource(
    client: client,
    networkChecker: networkChecker,
  );
});

/// Provider repository untuk mengabstraksi akses data materi pembelajaran.
final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  final dataSource = ref.watch(lessonDataSourceProvider);
  return LessonRepositoryImpl(dataSource);
});

/// Provider use case untuk memuat daftar materi berdasarkan ID kursus.
final getLessonsByCourseIdUseCaseProvider =
    Provider<GetLessonsByCourseIdUseCase>((ref) {
  final repository = ref.watch(lessonRepositoryProvider);
  return GetLessonsByCourseIdUseCase(repository);
});

/// Provider use case untuk memuat satu materi berdasarkan ID materi.
final getLessonByIdUseCaseProvider = Provider<GetLessonByIdUseCase>((ref) {
  final repository = ref.watch(lessonRepositoryProvider);
  return GetLessonByIdUseCase(repository);
});

/// Provider reaktif untuk memuat daftar materi kursus berdasarkan `courseId`.
///
/// Memanfaatkan `autoDispose` agar cache dilepas secara otomatis saat UI tidak lagi mengamati.
final lessonsByCourseProvider =
    FutureProvider.autoDispose.family<List<LessonEntity>, String>(
  (ref, courseId) async {
    final useCase = ref.watch(getLessonsByCourseIdUseCaseProvider);
    return useCase(courseId);
  },
);

/// Provider reaktif untuk memuat data materi spesifik berdasarkan `lessonId`.
final lessonDetailProvider =
    FutureProvider.autoDispose.family<LessonEntity, String>(
  (ref, lessonId) async {
    final useCase = ref.watch(getLessonByIdUseCaseProvider);
    return useCase(lessonId);
  },
);
