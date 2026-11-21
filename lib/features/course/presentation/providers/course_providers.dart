import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/data_sources/course_data_source.dart';
import '../../data/data_sources/supabase_course_data_source.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/get_course_by_id_usecase.dart';
import '../../domain/usecases/get_courses_usecase.dart';

/// Provider data source untuk fitur Course.
///
/// Menggunakan [SupabaseCourseDataSource] yang terhubung langsung ke Supabase PostgreSQL API.
final courseDataSourceProvider = Provider<CourseDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final networkChecker = ref.watch(networkCheckerProvider);
  return SupabaseCourseDataSource(
    client: client,
    networkChecker: networkChecker,
  );
});

/// Provider repository untuk mengabstraksi akses data kursus pembelajaran.
final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final dataSource = ref.watch(courseDataSourceProvider);
  return CourseRepositoryImpl(dataSource);
});

/// Provider use case untuk memuat seluruh daftar kursus.
final getCoursesUseCaseProvider = Provider<GetCoursesUseCase>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return GetCoursesUseCase(repository);
});

/// Provider use case untuk memuat detail satu kursus berdasarkan ID.
final getCourseByIdUseCaseProvider = Provider<GetCourseByIdUseCase>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return GetCourseByIdUseCase(repository);
});

/// Provider reaktif untuk memuat daftar seluruh kursus pembelajaran.
///
/// Disimpan di memori agar hasil preload dari splash screen langsung tersedia
/// tanpa loading berulang saat navigasi antar halaman.
final coursesListProvider =
    FutureProvider<List<CourseEntity>>((ref) async {
  final useCase = ref.watch(getCoursesUseCaseProvider);
  return useCase();
});

/// Provider reaktif untuk memuat detail satu kursus berdasarkan `courseId`.
final courseDetailProvider =
    FutureProvider.autoDispose.family<CourseEntity, String>(
  (ref, courseId) async {
    final useCase = ref.watch(getCourseByIdUseCaseProvider);
    return useCase(courseId);
  },
);
