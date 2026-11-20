import '../../../course/domain/entities/course_entity.dart';
import '../../../lesson/domain/entities/lesson_entity.dart';
import '../entities/course_progress_entity.dart';
import '../entities/overall_progress_entity.dart';

/// Use case murni (*pure Dart*) untuk menghitung progres kursus dan progres keseluruhan.
final class CalculateCourseProgressUseCase {
  const CalculateCourseProgressUseCase();

  /// Menghitung progres kursus berdasarkan daftar [lessons] dan [completedLessonIds].
  CourseProgressEntity calculateForLessons(
    List<LessonEntity> lessons,
    Set<String> completedLessonIds,
  ) {
    if (lessons.isEmpty) {
      return const CourseProgressEntity(
        completedCount: 0,
        totalCount: 0,
      );
    }

    final completedCount =
        lessons.where((lesson) => completedLessonIds.contains(lesson.id)).length;

    return CourseProgressEntity(
      completedCount: completedCount,
      totalCount: lessons.length,
    );
  }

  /// Menghitung progres satu [course] berdasarkan [completedLessonIds].
  CourseProgressEntity calculateForCourse(
    CourseEntity course,
    Set<String> completedLessonIds,
  ) {
    return calculateForLessons(course.lessons, completedLessonIds);
  }

  /// Menghitung ringkasan progres keseluruhan dari seluruh [courses] dan [completedLessonIds].
  OverallProgressEntity calculateOverall(
    List<CourseEntity> courses,
    Set<String> completedLessonIds,
  ) {
    if (courses.isEmpty) {
      return const OverallProgressEntity(
        completedLessonsCount: 0,
        totalLessonsCount: 0,
        completedCoursesCount: 0,
        totalCoursesCount: 0,
      );
    }

    int totalLessons = 0;
    int completedLessons = 0;
    int completedCourses = 0;

    for (final course in courses) {
      final progress = calculateForCourse(course, completedLessonIds);
      totalLessons += progress.totalCount;
      completedLessons += progress.completedCount;

      if (progress.isCompleted) {
        completedCourses++;
      }
    }

    return OverallProgressEntity(
      completedLessonsCount: completedLessons,
      totalLessonsCount: totalLessons,
      completedCoursesCount: completedCourses,
      totalCoursesCount: courses.length,
    );
  }
}
