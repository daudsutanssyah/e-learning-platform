import '../models/lesson_model.dart';

/// Kontrak sumber data untuk fitur Lesson.
///
/// Implementasi dapat berupa remote backend (Supabase / REST API)
/// maupun in-memory fake data source untuk pengujian otomatis.
abstract interface class LessonDataSource {
  /// Mengambil daftar materi berdasarkan ID kursus.
  Future<List<LessonModel>> fetchLessonsByCourseId(String courseId);

  /// Mengambil satu materi berdasarkan ID materi.
  Future<LessonModel> fetchLessonById(String lessonId);
}
