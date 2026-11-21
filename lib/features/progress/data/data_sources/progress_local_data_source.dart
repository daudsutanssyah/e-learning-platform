abstract interface class ProgressLocalDataSource {
  Future<List<String>> readCompletedLessonIds();

  Future<void> saveCompletedLessonIds(List<String> ids);

  Future<String?> readLastActiveCourseId();

  Future<void> saveLastActiveCourseId(String courseId);

  Future<String?> readLastActiveLessonId();

  Future<void> saveLastActiveLessonId(String lessonId);
}
