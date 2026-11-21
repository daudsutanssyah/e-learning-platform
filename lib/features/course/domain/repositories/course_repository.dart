import '../entities/course_entity.dart';

abstract interface class CourseRepository {
  Future<List<CourseEntity>> getCourses();

  Future<CourseEntity> getCourseById(String courseId);
}
