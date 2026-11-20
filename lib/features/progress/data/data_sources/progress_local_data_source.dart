/// Kontrak sumber data lokal untuk penyimpanan progres dan riwayat materi pembelajaran.
abstract interface class ProgressLocalDataSource {
  /// Membaca daftar ID materi yang telah diselesaikan dari penyimpanan lokal.
  Future<List<String>> readCompletedLessonIds();

  /// Menyimpan daftar ID materi yang telah diselesaikan ke penyimpanan lokal.
  Future<void> saveCompletedLessonIds(List<String> ids);

  /// Membaca ID kursus yang terakhir kali dibuka oleh pengguna.
  Future<String?> readLastActiveCourseId();

  /// Menyimpan ID kursus yang terakhir kali dibuka oleh pengguna.
  Future<void> saveLastActiveCourseId(String courseId);

  /// Membaca ID materi yang terakhir kali dibuka oleh pengguna.
  Future<String?> readLastActiveLessonId();

  /// Menyimpan ID materi yang terakhir kali dibuka oleh pengguna.
  Future<void> saveLastActiveLessonId(String lessonId);
}
