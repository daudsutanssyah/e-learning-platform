import '../models/course_model.dart';

abstract interface class CourseDataSource {
  Future<List<CourseModel>> fetchCourses();
  Future<CourseModel> fetchCourseById(String courseId);
}
