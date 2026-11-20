import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_learning_platform/features/course/data/data_sources/course_data_source.dart';
import 'package:e_learning_platform/features/course/data/models/course_model.dart';
import 'package:e_learning_platform/features/course/presentation/providers/course_providers.dart';
import 'package:e_learning_platform/features/lesson/data/models/lesson_model.dart';
import 'package:e_learning_platform/main.dart';

final class FakeCourseDataSource implements CourseDataSource {
  const FakeCourseDataSource();

  static const _sampleLesson = LessonModel(
    id: 'lesson-1',
    courseId: 'course-1',
    order: 1,
    title: 'Pengenalan Flutter',
    description: 'Dasar-dasar Flutter',
    durationSeconds: 600,
    videoUrl:
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  );

  static const _sampleCourse = CourseModel(
    id: 'course-1',
    title: 'Flutter Dasar',
    shortDescription: 'Belajar Flutter dari nol.',
    description: 'Belajar Flutter dari nol sampai mahir.',
    instructor: 'John Doe',
    thumbnailUrl:
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
    category: 'Mobile Development',
    level: 'Pemula',
    totalDurationSeconds: 600,
    lessons: [_sampleLesson],
  );

  @override
  Future<List<CourseModel>> fetchCourses() async => [_sampleCourse];

  @override
  Future<CourseModel> fetchCourseById(String courseId) async => _sampleCourse;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ELearningApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseDataSourceProvider.overrideWithValue(
            const FakeCourseDataSource(),
          ),
        ],
        child: const ELearningApp(),
      ),
    );

    // Biarkan seluruh future dan frame diselesaikan
    await tester.pumpAndSettle();

    // Memverifikasi widget root aplikasi berhasil di-render
    expect(find.byType(ELearningApp), findsOneWidget);
  });
}
