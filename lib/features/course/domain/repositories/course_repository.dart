import '../entities/course_entity.dart';

/// Kontrak repository untuk entitas [CourseEntity].
///
/// Mendefinisikan operasi bisnis untuk mengakses data kursus.
abstract interface class CourseRepository {
  /// Mengambil daftar seluruh kursus pembelajaran.
  Future<List<CourseEntity>> getCourses();

  /// Mengambil detail satu kursus spesifik berdasarkan ID kursus.
  Future<CourseEntity> getCourseById(String courseId);
}
