import '../../../../core/errors/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../data_sources/course_data_source.dart';

/// Implementasi [CourseRepository] yang menghubungkan layer domain ke data source.
final class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl(this._dataSource);

  final CourseDataSource _dataSource;

  @override
  Future<List<CourseEntity>> getCourses() async {
    try {
      final models = await _dataSource.fetchCourses();
      return models.map((model) => model.toEntity()).toList();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(
        'Terjadi kesalahan tak terduga saat memuat daftar kursus: $e',
      );
    }
  }

  @override
  Future<CourseEntity> getCourseById(String courseId) async {
    try {
      final model = await _dataSource.fetchCourseById(courseId);
      return model.toEntity();
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(
        'Terjadi kesalahan tak terduga saat memuat detail kursus: $e',
      );
    }
  }
}
