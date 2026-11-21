import '../entities/lesson_entity.dart';
import '../repositories/lesson_repository.dart';

final class GetLessonByIdUseCase {
  const GetLessonByIdUseCase(this._repository);

  final LessonRepository _repository;

  Future<LessonEntity> call(String lessonId) {
    return _repository.getLessonById(lessonId);
  }
}
