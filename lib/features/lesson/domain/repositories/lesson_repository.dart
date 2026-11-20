import '../entities/lesson_entity.dart';

/// Kontrak repository untuk entitas [LessonEntity].
///
/// Mendefinisikan operasi bisnis yang tersedia untuk materi pelajaran.
abstract interface class LessonRepository {
  /// Mengambil daftar seluruh materi berdasarkan ID kursus.
  Future<List<LessonEntity>> getLessonsByCourseId(String courseId);

  /// Mengambil satu materi spesifik berdasarkan ID materi.
  Future<LessonEntity> getLessonById(String lessonId);
}
