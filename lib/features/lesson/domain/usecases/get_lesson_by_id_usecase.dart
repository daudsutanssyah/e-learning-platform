import '../entities/lesson_entity.dart';
import '../repositories/lesson_repository.dart';

/// Use case untuk mengambil satu materi pembelajaran spesifik berdasarkan ID materi.
final class GetLessonByIdUseCase {
  const GetLessonByIdUseCase(this._repository);

  final LessonRepository _repository;

  Future<LessonEntity> call(String lessonId) {
    return _repository.getLessonById(lessonId);
  }
}
