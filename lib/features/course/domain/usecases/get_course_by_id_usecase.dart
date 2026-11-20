import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

/// Use case untuk mengambil data satu kursus spesifik berdasarkan ID kursus.
final class GetCourseByIdUseCase {
  const GetCourseByIdUseCase(this._repository);

  final CourseRepository _repository;

  Future<CourseEntity> call(String courseId) {
    return _repository.getCourseById(courseId);
  }
}
