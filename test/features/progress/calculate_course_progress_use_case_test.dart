import 'package:flutter_test/flutter_test.dart';
import 'package:e_learning_platform/features/course/domain/entities/course_entity.dart';
import 'package:e_learning_platform/features/lesson/domain/entities/lesson_entity.dart';
import 'package:e_learning_platform/features/progress/domain/usecases/calculate_course_progress_use_case.dart';

void main() {
  const useCase = CalculateCourseProgressUseCase();

  LessonEntity createLesson(String id, int order) {
    return LessonEntity(
      id: id,
      courseId: 'course-1',
      order: order,
      title: 'Lesson $order',
      description: 'Description',
      durationSeconds: 120,
      videoUrl: 'https://example.com/video.mp4',
    );
  }

  CourseEntity createCourse(String id, List<LessonEntity> lessons) {
    return CourseEntity(
      id: id,
      title: 'Course $id',
      shortDescription: 'Short desc',
      description: 'Long desc',
      category: 'Mobile Dev',
      level: 'Beginner',
      instructor: 'Mentor',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      totalDurationSeconds: 120 * lessons.length,
      lessons: lessons,
    );
  }

  group('CalculateCourseProgressUseCase', () {
    test(
        'menghitung progres kursus dengan 0 materi (0.0, isCompleted=false, tanpa divide-by-zero)',
        () {
      final course = createCourse('course-empty', []);
      final progress = useCase.calculateForCourse(course, {'some-id'});

      expect(progress.completedCount, 0);
      expect(progress.totalCount, 0);
      expect(progress.percentage, 0.0);
      expect(progress.percentageInt, 0);
      expect(progress.isCompleted, isFalse);
      expect(progress.isInProgress, isFalse);
    });

    test(
        'menghitung progres parsial (2 dari 4 materi -> 0.5, 50%, isInProgress=true)',
        () {
      final lessons = [
        createLesson('l1', 1),
        createLesson('l2', 2),
        createLesson('l3', 3),
        createLesson('l4', 4),
      ];
      final course = createCourse('course-1', lessons);
      final progress = useCase.calculateForCourse(course, {'l1', 'l3'});

      expect(progress.completedCount, 2);
      expect(progress.totalCount, 4);
      expect(progress.percentage, 0.5);
      expect(progress.percentageInt, 50);
      expect(progress.isCompleted, isFalse);
      expect(progress.isInProgress, isTrue);
    });

    test(
        'menghitung progres penuh (seluruh materi selesai -> 1.0, 100%, isCompleted=true)',
        () {
      final lessons = [
        createLesson('l1', 1),
        createLesson('l2', 2),
      ];
      final course = createCourse('course-1', lessons);
      final progress = useCase.calculateForCourse(course, {'l1', 'l2'});

      expect(progress.completedCount, 2);
      expect(progress.totalCount, 2);
      expect(progress.percentage, 1.0);
      expect(progress.percentageInt, 100);
      expect(progress.isCompleted, isTrue);
      expect(progress.isInProgress, isFalse);
    });

    test(
        'ID selesai yang tidak termasuk dalam kursus tertentu tidak ikut terhitung',
        () {
      final lessons = [
        createLesson('l1', 1),
        createLesson('l2', 2),
      ];
      final course = createCourse('course-1', lessons);
      final progress =
          useCase.calculateForCourse(course, {'unrelated-id', 'l1'});

      expect(progress.completedCount, 1);
      expect(progress.totalCount, 2);
      expect(progress.percentage, 0.5);
    });

    test('menghitung OverallProgressEntity lintas beberapa kursus', () {
      final c1Lessons = [
        createLesson('c1_l1', 1),
        createLesson('c1_l2', 2),
      ];
      final c2Lessons = [
        createLesson('c2_l1', 1),
        createLesson('c2_l2', 2),
        createLesson('c2_l3', 3),
      ];

      final courses = [
        createCourse('c1', c1Lessons),
        createCourse('c2', c2Lessons),
      ];

      // c1: 2/2 (completed), c2: 1/3 (in progress) -> total 3/5 lessons, 1/2 courses
      final completed = {'c1_l1', 'c1_l2', 'c2_l1'};
      final overall = useCase.calculateOverall(courses, completed);

      expect(overall.completedLessonsCount, 3);
      expect(overall.totalLessonsCount, 5);
      expect(overall.completedCoursesCount, 1);
      expect(overall.totalCoursesCount, 2);
      expect(overall.percentage, 0.6);
      expect(overall.percentageInt, 60);
    });
  });
}
