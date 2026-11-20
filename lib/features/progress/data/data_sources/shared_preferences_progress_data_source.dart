import 'package:shared_preferences/shared_preferences.dart';

import 'progress_local_data_source.dart';

/// Implementasi [ProgressLocalDataSource] berbasis [SharedPreferences].
final class SharedPreferencesProgressDataSource
    implements ProgressLocalDataSource {
  const SharedPreferencesProgressDataSource();

  static const String _kCompletedLessonIdsKey = 'completed_lesson_ids';
  static const String _kLastActiveCourseIdKey = 'last_active_course_id';
  static const String _kLastActiveLessonIdKey = 'last_active_lesson_id';

  @override
  Future<List<String>> readCompletedLessonIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kCompletedLessonIdsKey) ?? const [];
  }

  @override
  Future<void> saveCompletedLessonIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kCompletedLessonIdsKey, ids);
  }

  @override
  Future<String?> readLastActiveCourseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastActiveCourseIdKey);
  }

  @override
  Future<void> saveLastActiveCourseId(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastActiveCourseIdKey, courseId);
  }

  @override
  Future<String?> readLastActiveLessonId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastActiveLessonIdKey);
  }

  @override
  Future<void> saveLastActiveLessonId(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastActiveLessonIdKey, lessonId);
  }
}
