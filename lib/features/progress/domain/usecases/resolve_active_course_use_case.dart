import '../../../course/domain/entities/course_entity.dart';
import '../../../lesson/domain/entities/lesson_entity.dart';
import '../entities/course_progress_entity.dart';
import '../entities/learning_progress_state.dart';
import 'calculate_course_progress_use_case.dart';

/// Hasil analisis resolusi kelas aktif, materi lanjutan, dan rekomendasi kursus.
final class ActiveCourseResolution {
  const ActiveCourseResolution({
    required this.activeCourse,
    required this.nextLesson,
    required this.nextRecommendedCourse,
    required this.activeCourseProgress,
    required this.recommendedFirstCourse,
  });

  /// Kursus yang sedang aktif dipelajari (`null` jika Cold Start).
  final CourseEntity? activeCourse;

  /// Materi lanjutan yang belum selesai pada kursus aktif (`null` jika semua tuntas atau Cold Start).
  final LessonEntity? nextLesson;

  /// Kursus rekomendasi lain berikutnya jika kursus aktif sudah 100% tuntas (`null` jika seluruh katalog selesai).
  final CourseEntity? nextRecommendedCourse;

  /// Progres kalkulasi pada kursus aktif (`null` jika Cold Start).
  final CourseProgressEntity? activeCourseProgress;

  /// Kursus pertama dari katalog sebagai panduan untuk Sambutan Awal (Cold Start).
  final CourseEntity? recommendedFirstCourse;

  /// Menandakan apakah pengguna berada pada state Sambutan Awal (belum pernah membuka kursus apa pun).
  bool get isColdStart => activeCourse == null;

  /// Menandakan apakah kelas aktif sedang dalam proses belajar (belum 100% tuntas).
  bool get isInProgress =>
      activeCourse != null &&
      activeCourseProgress != null &&
      !activeCourseProgress!.isCompleted;

  /// Menandakan apakah kelas aktif sudah 100% selesai seluruh materinya.
  bool get isCompleted =>
      activeCourse != null &&
      activeCourseProgress != null &&
      activeCourseProgress!.isCompleted;
}

/// Use case murni (*pure Dart*) untuk menentukan status kelas aktif, materi lanjutan,
/// dan rekomendasi kursus berikutnya berdasarkan riwayat lokal pengguna.
final class ResolveActiveCourseUseCase {
  const ResolveActiveCourseUseCase({
    this.calculateProgressUseCase = const CalculateCourseProgressUseCase(),
  });

  final CalculateCourseProgressUseCase calculateProgressUseCase;

  ActiveCourseResolution resolve({
    required List<CourseEntity> courses,
    required LearningProgressState progressState,
  }) {
    final recommendedFirstCourse = courses.isNotEmpty ? courses.first : null;

    if (courses.isEmpty) {
      return const ActiveCourseResolution(
        activeCourse: null,
        nextLesson: null,
        nextRecommendedCourse: null,
        activeCourseProgress: null,
        recommendedFirstCourse: null,
      );
    }

    // 1. Tentukan activeCourse berdasarkan lastActiveCourseId
    CourseEntity? activeCourse;
    if (progressState.lastActiveCourseId != null) {
      for (final course in courses) {
        if (course.id == progressState.lastActiveCourseId) {
          activeCourse = course;
          break;
        }
      }
    }

    // Jika lastActiveCourseId belum tercatat atau tidak ditemukan pada katalog -> Cold Start
    if (activeCourse == null) {
      return ActiveCourseResolution(
        activeCourse: null,
        nextLesson: null,
        nextRecommendedCourse: null,
        activeCourseProgress: null,
        recommendedFirstCourse: recommendedFirstCourse,
      );
    }

    // 2. Hitung progres kursus aktif
    final progress = calculateProgressUseCase.calculateForCourse(
      activeCourse,
      progressState.completedLessonIds,
    );

    // 3. Tentukan nextLesson untuk activeCourse
    LessonEntity? nextLesson;
    if (!progress.isCompleted && activeCourse.lessons.isNotEmpty) {
      // Prioritas 1: Jika lastActiveLessonId ada di activeCourse dan belum diselesaikan
      if (progressState.lastActiveLessonId != null) {
        for (final lesson in activeCourse.lessons) {
          if (lesson.id == progressState.lastActiveLessonId &&
              !progressState.completedLessonIds.contains(lesson.id)) {
            nextLesson = lesson;
            break;
          }
        }
      }

      // Prioritas 2: Cari materi pertama (urut order ascending) yang belum selesai
      if (nextLesson == null) {
        final sortedLessons = [...activeCourse.lessons]
          ..sort((a, b) => a.order.compareTo(b.order));
        for (final lesson in sortedLessons) {
          if (!progressState.completedLessonIds.contains(lesson.id)) {
            nextLesson = lesson;
            break;
          }
        }
      }
    }

    // 4. Tentukan nextRecommendedCourse jika activeCourse sudah tuntas 100%
    CourseEntity? nextRecommendedCourse;
    if (progress.isCompleted) {
      for (final course in courses) {
        if (course.id == activeCourse.id) continue;
        final courseProgress = calculateProgressUseCase.calculateForCourse(
          course,
          progressState.completedLessonIds,
        );
        if (!courseProgress.isCompleted) {
          nextRecommendedCourse = course;
          break;
        }
      }
    }

    return ActiveCourseResolution(
      activeCourse: activeCourse,
      nextLesson: nextLesson,
      nextRecommendedCourse: nextRecommendedCourse,
      activeCourseProgress: progress,
      recommendedFirstCourse: recommendedFirstCourse,
    );
  }
}
