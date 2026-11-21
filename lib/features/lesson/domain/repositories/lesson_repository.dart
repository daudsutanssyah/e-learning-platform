import '../entities/lesson_entity.dart';

abstract interface class LessonRepository {
  Future<List<LessonEntity>> getLessonsByCourseId(String courseId);

  Future<LessonEntity> getLessonById(String lessonId);
}
