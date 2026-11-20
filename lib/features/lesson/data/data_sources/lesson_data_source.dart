import '../../../../core/constants/app_assets.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_json_service.dart';
import '../models/lesson_model.dart';

/// Kontrak sumber data untuk fitur Lesson.
///
/// Panduan migrasi ke REST API sungguhan:
/// - `fetchLessonsByCourseId`: ekuivalen dengan `GET /api/v1/courses/{courseId}/lessons`
/// - `fetchLessonById`: ekuivalen dengan `GET /api/v1/lessons/{lessonId}`
///
/// Saat beralih ke backend remote, buat implementasi baru `RemoteLessonDataSource`
/// menggunakan HTTP client tanpa mengubah kontrak ini maupun layer domain.
abstract interface class LessonDataSource {
  /// Mengambil daftar materi berdasarkan ID kursus.
  Future<List<LessonModel>> fetchLessonsByCourseId(String courseId);

  /// Mengambil satu materi berdasarkan ID materi.
  Future<LessonModel> fetchLessonById(String lessonId);
}

/// Implementasi mock data source yang membaca file JSON lokal.
final class MockLessonDataSource implements LessonDataSource {
  const MockLessonDataSource(this._localJsonService);

  final LocalJsonService _localJsonService;

  Future<List<Map<String, dynamic>>> _loadCoursesData() async {
    final jsonObject = await _localJsonService.loadJsonObject(
      AppAssets.coursesMockJson,
    );

    final status = jsonObject['status'];
    final data = jsonObject['data'];

    if (status != 'success' || data is! List) {
      throw const DataParsingFailure(
        'Format respons mock data tidak valid atau field data bukan list.',
      );
    }

    return data.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Future<List<LessonModel>> fetchLessonsByCourseId(String courseId) async {
    final courses = await _loadCoursesData();

    Map<String, dynamic>? targetCourse;
    for (final course in courses) {
      if (course['id'] == courseId) {
        targetCourse = course;
        break;
      }
    }

    if (targetCourse == null) {
      throw NotFoundFailure(
        'Kursus dengan ID "$courseId" tidak ditemukan.',
      );
    }

    final rawLessons = targetCourse['lessons'];
    if (rawLessons is! List) {
      throw const DataParsingFailure(
        'Field "lessons" pada kursus tidak valid atau bukan list.',
      );
    }

    final lessons = <LessonModel>[];
    for (final rawLesson in rawLessons) {
      if (rawLesson is! Map<String, dynamic>) {
        throw const DataParsingFailure(
          'Item lesson dalam kursus harus berupa objek JSON.',
        );
      }
      lessons.add(LessonModel.fromJson(rawLesson));
    }

    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  @override
  Future<LessonModel> fetchLessonById(String lessonId) async {
    final courses = await _loadCoursesData();

    for (final course in courses) {
      final rawLessons = course['lessons'];
      if (rawLessons is! List) continue;

      for (final rawLesson in rawLessons) {
        if (rawLesson is Map<String, dynamic> && rawLesson['id'] == lessonId) {
          return LessonModel.fromJson(rawLesson);
        }
      }
    }

    throw NotFoundFailure(
      'Materi dengan ID "$lessonId" tidak ditemukan.',
    );
  }
}
