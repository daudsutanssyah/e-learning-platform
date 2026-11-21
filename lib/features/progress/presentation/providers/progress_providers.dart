import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../course/domain/entities/course_entity.dart';
import '../../../course/presentation/providers/course_providers.dart';
import '../../data/data_sources/progress_local_data_source.dart';
import '../../data/data_sources/shared_preferences_progress_data_source.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/course_progress_entity.dart';
import '../../domain/entities/learning_progress_state.dart';
import '../../domain/entities/overall_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../../domain/usecases/calculate_course_progress_use_case.dart';
import '../../domain/usecases/resolve_active_course_use_case.dart';

/// Provider sumber data lokal untuk progres pembelajaran.
final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  return const SharedPreferencesProgressDataSource();
});

/// Provider repositori untuk persistensi progres pembelajaran.
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dataSource = ref.watch(progressLocalDataSourceProvider);
  return ProgressRepositoryImpl(dataSource);
});

/// Provider use case perhitungan progres kursus dan keseluruhan.
final calculateCourseProgressUseCaseProvider =
    Provider<CalculateCourseProgressUseCase>((ref) {
  return const CalculateCourseProgressUseCase();
});

/// Provider use case resolusi kelas aktif dan rekomendasi berikutnya.
final resolveActiveCourseUseCaseProvider =
    Provider<ResolveActiveCourseUseCase>((ref) {
  final calculateProgressUseCase =
      ref.watch(calculateCourseProgressUseCaseProvider);
  return ResolveActiveCourseUseCase(
    calculateProgressUseCase: calculateProgressUseCase,
  );
});

/// Notifier reaktif pengelola status progres dan riwayat belajar lokal.
final progressNotifierProvider =
    AsyncNotifierProvider<ProgressNotifier, LearningProgressState>(
  ProgressNotifier.new,
);

class ProgressNotifier extends AsyncNotifier<LearningProgressState> {
  @override
  Future<LearningProgressState> build() async {
    final repository = ref.watch(progressRepositoryProvider);
    return repository.getProgressState();
  }

  /// Menandai materi sebagai selesai secara idempoten dengan *optimistic update*.
  Future<void> markCompleted(String lessonId) async {
    final current = state.value ?? const LearningProgressState();
    if (current.completedLessonIds.contains(lessonId)) return;

    final updatedSet = {...current.completedLessonIds, lessonId};
    state = AsyncData(current.copyWith(completedLessonIds: updatedSet));

    try {
      final persisted = await ref
          .read(progressRepositoryProvider)
          .markLessonCompleted(lessonId);
      state = AsyncData(persisted);
    } catch (e, st) {
      debugPrint('Gagal menyimpan progres materi: $e\n$st');
    }
  }

  Future<void> toggleCompleted(String lessonId) async {
    final current = state.value ?? const LearningProgressState();
    final updatedSet = Set<String>.from(current.completedLessonIds);

    if (updatedSet.contains(lessonId)) {
      updatedSet.remove(lessonId);
    } else {
      updatedSet.add(lessonId);
    }

    state = AsyncData(current.copyWith(completedLessonIds: updatedSet));

    try {
      final persisted = await ref
          .read(progressRepositoryProvider)
          .toggleLessonCompleted(lessonId);
      state = AsyncData(persisted);
    } catch (e, st) {
      debugPrint('Gagal mengubah status progres materi: $e\n$st');
    }
  }

  /// Mencatat bahwa kursus tertentu telah dibuka oleh pengguna (tanpa memblokir UI).
  Future<void> recordCourseOpened(String courseId) async {
    final current = state.value ?? const LearningProgressState();
    if (current.lastActiveCourseId == courseId) return;

    state = AsyncData(current.copyWith(
      lastActiveCourseId: () => courseId,
    ));

    try {
      final persisted = await ref
          .read(progressRepositoryProvider)
          .setLastActiveCourse(courseId);
      state = AsyncData(persisted);
    } catch (e, st) {
      debugPrint('Gagal mencatat kursus aktif: $e\n$st');
    }
  }

  /// Mencatat bahwa materi tertentu sedang dibuka/dipelajari beserta kursusnya.
  Future<void> recordLessonOpened({
    required String courseId,
    required String lessonId,
  }) async {
    final current = state.value ?? const LearningProgressState();
    if (current.lastActiveCourseId == courseId &&
        current.lastActiveLessonId == lessonId) {
      return;
    }

    state = AsyncData(current.copyWith(
      lastActiveCourseId: () => courseId,
      lastActiveLessonId: () => lessonId,
    ));

    try {
      final persisted = await ref
          .read(progressRepositoryProvider)
          .setLastActiveLesson(courseId: courseId, lessonId: lessonId);
      state = AsyncData(persisted);
    } catch (e, st) {
      debugPrint('Gagal mencatat materi aktif: $e\n$st');
    }
  }
}

/// Provider penyedia kumpulan ID materi yang selesai (fallback ke set kosong saat loading/error).
final completedLessonIdsProvider = Provider<Set<String>>((ref) {
  final asyncValue = ref.watch(progressNotifierProvider);
  return asyncValue.value?.completedLessonIds ?? const <String>{};
});

/// Provider pengecekan status penyelesaian materi tertentu berdasarkan [lessonId].
final isLessonCompletedProvider = Provider.family<bool, String>((ref, lessonId) {
  final completedIds = ref.watch(completedLessonIdsProvider);
  return completedIds.contains(lessonId);
});

/// Provider penghitung progres satu kursus secara reaktif berdasarkan [course].
final courseProgressProvider =
    Provider.family<CourseProgressEntity, CourseEntity>((ref, course) {
  final completedIds = ref.watch(completedLessonIdsProvider);
  final useCase = ref.watch(calculateCourseProgressUseCaseProvider);
  return useCase.calculateForCourse(course, completedIds);
});

/// Provider penghitung progres keseluruhan akun/perangkat dari seluruh kursus yang ada.
final overallProgressProvider = Provider<OverallProgressEntity>((ref) {
  final courses = ref.watch(coursesListProvider).value ?? const [];
  final completedIds = ref.watch(completedLessonIdsProvider);
  final useCase = ref.watch(calculateCourseProgressUseCaseProvider);
  return useCase.calculateOverall(courses, completedIds);
});

/// Provider hasil resolusi status kelas aktif, materi lanjutan, dan rekomendasi berikutnya.
final activeCourseResolutionProvider = Provider<ActiveCourseResolution>((ref) {
  final courses = ref.watch(coursesListProvider).value ?? const [];
  final progressState = ref.watch(progressNotifierProvider).value ??
      const LearningProgressState();
  final useCase = ref.watch(resolveActiveCourseUseCaseProvider);
  return useCase.resolve(courses: courses, progressState: progressState);
});

/// Status filter kursus pada katalog utama.
enum CourseFilterStatus {
  all,
  inProgress,
  completed,
}

/// Notifier pengelola status filter aktif pada katalog kursus.
final courseFilterProvider =
    NotifierProvider<CourseFilterNotifier, CourseFilterStatus>(
  CourseFilterNotifier.new,
);

class CourseFilterNotifier extends Notifier<CourseFilterStatus> {
  @override
  CourseFilterStatus build() => CourseFilterStatus.all;

  void setFilter(CourseFilterStatus status) {
    if (state != status) {
      state = status;
    }
  }
}

/// Model data jumlah kursus untuk setiap kategori filter.
final class CourseFilterCounts {
  const CourseFilterCounts({
    required this.all,
    required this.inProgress,
    required this.completed,
  });

  final int all;
  final int inProgress;
  final int completed;
}

/// Provider penghitung jumlah kursus per filter status.
final courseFilterCountsProvider = Provider<CourseFilterCounts>((ref) {
  final courses = ref.watch(coursesListProvider).value ?? const [];
  final completedIds = ref.watch(completedLessonIdsProvider);
  final useCase = ref.watch(calculateCourseProgressUseCaseProvider);

  int inProgressCount = 0;
  int completedCount = 0;

  for (final course in courses) {
    final progress = useCase.calculateForCourse(course, completedIds);
    if (progress.isCompleted) {
      completedCount++;
    } else if (progress.isInProgress) {
      inProgressCount++;
    }
  }

  return CourseFilterCounts(
    all: courses.length,
    inProgress: inProgressCount,
    completed: completedCount,
  );
});

/// Provider daftar kursus yang telah disaring berdasarkan [courseFilterProvider].
final filteredCoursesProvider = Provider<List<CourseEntity>>((ref) {
  final courses = ref.watch(coursesListProvider).value ?? const [];
  final filter = ref.watch(courseFilterProvider);
  final completedIds = ref.watch(completedLessonIdsProvider);
  final useCase = ref.watch(calculateCourseProgressUseCaseProvider);

  switch (filter) {
    case CourseFilterStatus.all:
      return courses;
    case CourseFilterStatus.inProgress:
      return courses.where((c) {
        final progress = useCase.calculateForCourse(c, completedIds);
        return progress.isInProgress;
      }).toList();
    case CourseFilterStatus.completed:
      return courses.where((c) {
        final progress = useCase.calculateForCourse(c, completedIds);
        return progress.isCompleted;
      }).toList();
  }
});
