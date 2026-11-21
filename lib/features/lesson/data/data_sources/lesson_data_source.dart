import '../models/lesson_model.dart';

abstract interface class LessonDataSource {
  Future<List<LessonModel>> fetchLessonsByCourseId(String courseId);

  Future<LessonModel> fetchLessonById(String lessonId);
}
