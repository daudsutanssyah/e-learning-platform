import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

/// Use case untuk mengambil daftar seluruh kursus pembelajaran.
final class GetCoursesUseCase {
  const GetCoursesUseCase(this._repository);

  final CourseRepository _repository;

  Future<List<CourseEntity>> call() {
    return _repository.getCourses();
  }
}
