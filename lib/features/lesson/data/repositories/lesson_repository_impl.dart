import '../../../../core/errors/failures.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../data_sources/lesson_data_source.dart';

/// Implementasi [LessonRepository] yang menghubungkan layer domain ke data source.
final class LessonRepositoryImpl implements LessonRepository {
  const LessonRepositoryImpl(this._dataSource);

  final LessonDataSource _dataSource;

  @override
  Future<List<LessonEntity>> getLessonsByCourseId(String courseId) async {
    try {
      final models = await _dataSource.fetchLessonsByCourseId(courseId);
      return models.map((model) => model.toEntity()).toList();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(
        'Terjadi kesalahan tak terduga saat memuat materi: $e',
      );
    }
  }

  @override
  Future<LessonEntity> getLessonById(String lessonId) async {
    try {
      final model = await _dataSource.fetchLessonById(lessonId);
      return model.toEntity();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(
        'Terjadi kesalahan tak terduga saat memuat materi: $e',
      );
    }
  }
}
