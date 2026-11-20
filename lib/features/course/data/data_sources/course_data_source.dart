import '../../../../core/constants/app_assets.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/local_json_service.dart';
import '../models/course_model.dart';

/// Kontrak sumber data untuk fitur Course.
///
/// Panduan migrasi ke REST API sungguhan:
/// - `fetchCourses`: ekuivalen dengan `GET /api/v1/courses`
/// - `fetchCourseById`: ekuivalen dengan `GET /api/v1/courses/{courseId}`
///
/// Untuk beralih dari mock JSON lokal ke remote backend:
/// 1. Buat kelas baru `RemoteCourseDataSource implements CourseDataSource`
///    menggunakan HTTP client (misalnya `http` atau `dio`).
/// 2. Ganti binding dependency injection provider pada presentation/di layer
///    ke `RemoteCourseDataSource`.
/// 3. Layer domain (use cases, repository interface, entities) dan UI
///    tetap utuh tanpa perlu modifikasi apa pun.
abstract interface class CourseDataSource {
  /// Mengambil daftar seluruh kursus pembelajaran.
  Future<List<CourseModel>> fetchCourses();

  /// Mengambil data detail kursus berdasarkan ID kursus.
  Future<CourseModel> fetchCourseById(String courseId);
}

/// Implementasi mock data source yang membaca file JSON lokal.
final class MockCourseDataSource implements CourseDataSource {
  const MockCourseDataSource(this._localJsonService);

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
  Future<List<CourseModel>> fetchCourses() async {
    final coursesData = await _loadCoursesData();
    if (coursesData.isEmpty) {
      return const [];
    }

    return coursesData
        .map((courseJson) => CourseModel.fromJson(courseJson))
        .toList();
  }

  @override
  Future<CourseModel> fetchCourseById(String courseId) async {
    final coursesData = await _loadCoursesData();

    for (final courseJson in coursesData) {
      if (courseJson['id'] == courseId) {
        return CourseModel.fromJson(courseJson);
      }
    }

    throw NotFoundFailure(
      'Kursus dengan ID "$courseId" tidak ditemukan.',
    );
  }
}
