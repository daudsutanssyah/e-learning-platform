final class AppRoutes {
  const AppRoutes._();

  /// Rute splash screen animasi.
  static const String splashPath = '/splash';
  static const String splashName = 'splash';

  /// Rute daftar kursus (katalog utama).
  static const String courseListPath = '/';
  static const String courseListName = 'course_list';

  /// Rute detail kursus beserta silabus materi.
  static const String courseDetailPath = '/courses/:courseId';
  static const String courseDetailName = 'course_detail';

  /// Rute pemutar materi pembelajaran.
  static const String lessonPlayerPath = '/courses/:courseId/lessons/:lessonId';
  static const String lessonPlayerName = 'lesson_player';

  /// Membangun path detail kursus berdasarkan [courseId].
  static String courseDetail(String courseId) => '/courses/$courseId';

  /// Membangun path pemutar materi berdasarkan [courseId] dan [lessonId].
  static String lessonPlayer(String courseId, String lessonId) =>
      '/courses/$courseId/lessons/$lessonId';
}
