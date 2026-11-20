import '../models/course_model.dart';

/// Kontrak sumber data untuk fitur Course.
///
/// Implementasi dapat berupa remote backend (Supabase / REST API)
/// maupun in-memory fake data source untuk pengujian otomatis.
abstract interface class CourseDataSource {
  /// Mengambil daftar seluruh kursus pembelajaran.
  Future<List<CourseModel>> fetchCourses();

  /// Mengambil data detail kursus berdasarkan ID kursus.
  Future<CourseModel> fetchCourseById(String courseId);
}
