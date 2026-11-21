import '../entities/lesson_entity.dart';
import '../repositories/lesson_repository.dart';

final class GetLessonsByCourseIdUseCase {
  const GetLessonsByCourseIdUseCase(this._repository);

  final LessonRepository _repository;

  Future<List<LessonEntity>> call(String courseId) {
    return _repository.getLessonsByCourseId(courseId);
  }
}
