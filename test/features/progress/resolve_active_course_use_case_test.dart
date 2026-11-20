import 'package:flutter_test/flutter_test.dart';
import 'package:e_learning_platform/features/course/domain/entities/course_entity.dart';
import 'package:e_learning_platform/features/lesson/domain/entities/lesson_entity.dart';
import 'package:e_learning_platform/features/progress/domain/entities/learning_progress_state.dart';
import 'package:e_learning_platform/features/progress/domain/usecases/resolve_active_course_use_case.dart';

void main() {
  const useCase = ResolveActiveCourseUseCase();

  LessonEntity createLesson({
    required String id,
    required String courseId,
    required int order,
    String? title,
  }) {
    return LessonEntity(
      id: id,
      courseId: courseId,
      order: order,
      title: title ?? 'Lesson $order',
      description: 'Description for lesson $order',
      durationSeconds: 120,
      videoUrl: 'https://example.com/video.mp4',
    );
  }

  CourseEntity createCourse({
    required String id,
    required String title,
    required List<LessonEntity> lessons,
  }) {
    return CourseEntity(
      id: id,
      title: title,
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

  final course1 = createCourse(
    id: 'c1',
    title: 'Flutter Dasar',
    lessons: [
      createLesson(id: 'c1_l1', courseId: 'c1', order: 1, title: 'Intro'),
      createLesson(id: 'c1_l2', courseId: 'c1', order: 2, title: 'Widgets'),
      createLesson(id: 'c1_l3', courseId: 'c1', order: 3, title: 'State'),
    ],
  );

  final course2 = createCourse(
    id: 'c2',
    title: 'Flutter Lanjutan',
    lessons: [
      createLesson(id: 'c2_l1', courseId: 'c2', order: 1, title: 'Architecture'),
      createLesson(id: 'c2_l2', courseId: 'c2', order: 2, title: 'Testing'),
    ],
  );

  final allCourses = [course1, course2];

  group('ResolveActiveCourseUseCase', () {
    test(
      'Skenario 1: Cold start saat lastActiveCourseId null -> isColdStart=true, recommendedFirstCourse=c1',
      () {
        const state = LearningProgressState(
          lastActiveCourseId: null,
          lastActiveLessonId: null,
          completedLessonIds: {},
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isColdStart, isTrue);
        expect(result.activeCourse, isNull);
        expect(result.nextLesson, isNull);
        expect(result.activeCourseProgress, isNull);
        expect(result.recommendedFirstCourse?.id, 'c1');
      },
    );

    test(
      'Skenario 2: lastActiveCourseId tidak ada di daftar kursus -> fallback ke Cold Start',
      () {
        const state = LearningProgressState(
          lastActiveCourseId: 'unknown-id',
          lastActiveLessonId: null,
          completedLessonIds: {},
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isColdStart, isTrue);
        expect(result.activeCourse, isNull);
        expect(result.recommendedFirstCourse?.id, 'c1');
      },
    );

    test(
      'Skenario 3: Kelas aktif sedang dipelajari dan lastActiveLessonId belum selesai -> nextLesson memakai lastActiveLessonId',
      () {
        const state = LearningProgressState(
          lastActiveCourseId: 'c1',
          lastActiveLessonId: 'c1_l2',
          completedLessonIds: {'c1_l1'},
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isColdStart, isFalse);
        expect(result.isInProgress, isTrue);
        expect(result.isCompleted, isFalse);
        expect(result.activeCourse?.id, 'c1');
        expect(result.nextLesson?.id, 'c1_l2');
        expect(result.activeCourseProgress?.completedCount, 1);
        expect(result.activeCourseProgress?.totalCount, 3);
        expect(result.activeCourseProgress?.percentageInt, 33);
      },
    );

    test(
      'Skenario 4: Kelas aktif di mana lastActiveLessonId SUDAH selesai -> nextLesson otomatis memilih materi berikutnya yang belum selesai',
      () {
        // Pengguna terakhir membuka c1_l2, tapi c1_l1 dan c1_l2 sudah selesai
        const state = LearningProgressState(
          lastActiveCourseId: 'c1',
          lastActiveLessonId: 'c1_l2',
          completedLessonIds: {'c1_l1', 'c1_l2'},
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isInProgress, isTrue);
        expect(result.activeCourse?.id, 'c1');
        expect(result.nextLesson?.id, 'c1_l3'); // otomatis lompat ke materi ke-3
        expect(result.activeCourseProgress?.completedCount, 2);
        expect(result.activeCourseProgress?.percentageInt, 67);
      },
    );

    test(
      'Skenario 5: Kelas aktif 100% tuntas -> isCompleted=true, merekomendasikan kursus lain yang belum tuntas',
      () {
        // c1 selesai 100% (c1_l1, c1_l2, c1_l3)
        const state = LearningProgressState(
          lastActiveCourseId: 'c1',
          lastActiveLessonId: 'c1_l3',
          completedLessonIds: {'c1_l1', 'c1_l2', 'c1_l3'},
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isCompleted, isTrue);
        expect(result.isInProgress, isFalse);
        expect(result.nextLesson, isNull);
        expect(result.activeCourseProgress?.isCompleted, isTrue);
        expect(result.activeCourseProgress?.percentageInt, 100);
        expect(result.nextRecommendedCourse?.id, 'c2'); // c2 belum tuntas
      },
    );

    test(
      'Skenario 6: Seluruh kursus dalam katalog telah tuntas 100% -> nextRecommendedCourse=null',
      () {
        // Semua kursus selesai
        const state = LearningProgressState(
          lastActiveCourseId: 'c1',
          lastActiveLessonId: 'c1_l3',
          completedLessonIds: {
            'c1_l1',
            'c1_l2',
            'c1_l3',
            'c2_l1',
            'c2_l2',
          },
        );

        final result = useCase.resolve(
          courses: allCourses,
          progressState: state,
        );

        expect(result.isCompleted, isTrue);
        expect(result.activeCourse?.id, 'c1');
        expect(result.nextRecommendedCourse, isNull); // semua sudah tuntas
      },
    );

    test(
      'Skenario 7: Katalog kursus kosong -> aman tanpa exception',
      () {
        const state = LearningProgressState(
          lastActiveCourseId: 'c1',
          completedLessonIds: {},
        );

        final result = useCase.resolve(
          courses: [],
          progressState: state,
        );

        expect(result.isColdStart, isTrue);
        expect(result.activeCourse, isNull);
        expect(result.recommendedFirstCourse, isNull);
      },
    );
  });
}
