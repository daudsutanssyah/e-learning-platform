import '../entities/learning_progress_state.dart';

/// Kontrak repositori untuk mengelola persistensi progres pembelajaran.
abstract interface class ProgressRepository {
  /// Mengambil state progres pembelajaran lengkap (materi selesai & kelas/materi aktif).
  Future<LearningProgressState> getProgressState();

  /// Mengambil kumpulan ID materi (`Set<String>`) yang telah diselesaikan.
  Future<Set<String>> getCompletedLessonIds();

  /// Mencatat kursus yang sedang aktif dibuka oleh pengguna.
  ///
  /// Mengembalikan state progres terbaru setelah disimpan.
  Future<LearningProgressState> setLastActiveCourse(String courseId);

  /// Mencatat materi yang sedang aktif dibuka/dipelajari beserta kursusnya.
  ///
  /// Mengembalikan state progres terbaru setelah disimpan.
  Future<LearningProgressState> setLastActiveLesson({
    required String courseId,
    required String lessonId,
  });

  /// Menandai materi dengan [lessonId] sebagai selesai secara idempoten.
  ///
  /// Mengembalikan state progres terbaru setelah disimpan.
  Future<LearningProgressState> markLessonCompleted(String lessonId);

  /// Mengubah status penyelesaian materi (toggle: selesai/belum selesai).
  ///
  /// Mengembalikan state progres terbaru setelah disimpan.
  Future<LearningProgressState> toggleLessonCompleted(String lessonId);
}
