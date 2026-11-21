import '../../../course/domain/entities/course_entity.dart';
import '../../../lesson/domain/entities/lesson_entity.dart';
import '../entities/course_progress_entity.dart';
import '../entities/learning_progress_state.dart';
import 'calculate_course_progress_use_case.dart';

final class ActiveCourseResolution {
  const ActiveCourseResolution({
    required this.activeCourse,
    required this.nextLesson,
    required this.nextRecommendedCourse,
    required this.activeCourseProgress,
    required this.recommendedFirstCourse,
  });

  final CourseEntity? activeCourse;

  final LessonEntity? nextLesson;
  final CourseEntity? nextRecommendedCourse;

  final CourseProgressEntity? activeCourseProgress;

  final CourseEntity? recommendedFirstCourse;

  bool get isColdStart => activeCourse == null;

  bool get isInProgress =>
      activeCourse != null &&
      activeCourseProgress != null &&
      !activeCourseProgress!.isCompleted;

  bool get isCompleted =>
      activeCourse != null &&
      activeCourseProgress != null &&
      activeCourseProgress!.isCompleted;
}

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

    CourseEntity? activeCourse;
    if (progressState.lastActiveCourseId != null) {
      for (final course in courses) {
        if (course.id == progressState.lastActiveCourseId) {
          activeCourse = course;
          break;
        }
      }
    }

    if (activeCourse == null) {
      return ActiveCourseResolution(
        activeCourse: null,
        nextLesson: null,
        nextRecommendedCourse: null,
        activeCourseProgress: null,
        recommendedFirstCourse: recommendedFirstCourse,
      );
    }

    final progress = calculateProgressUseCase.calculateForCourse(
      activeCourse,
      progressState.completedLessonIds,
    );

    LessonEntity? nextLesson;
    if (!progress.isCompleted && activeCourse.lessons.isNotEmpty) {
      if (progressState.lastActiveLessonId != null) {
        for (final lesson in activeCourse.lessons) {
          if (lesson.id == progressState.lastActiveLessonId &&
              !progressState.completedLessonIds.contains(lesson.id)) {
            nextLesson = lesson;
            break;
          }
        }
      }

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
