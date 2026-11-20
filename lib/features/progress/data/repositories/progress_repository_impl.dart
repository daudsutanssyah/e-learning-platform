import '../../domain/entities/learning_progress_state.dart';
import '../../domain/repositories/progress_repository.dart';
import '../data_sources/progress_local_data_source.dart';

/// Implementasi [ProgressRepository] untuk mengelola persistensi progres dan riwayat belajar lokal.
final class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl(this._dataSource);

  final ProgressLocalDataSource _dataSource;

  @override
  Future<LearningProgressState> getProgressState() async {
    final completedList = await _dataSource.readCompletedLessonIds();
    final lastCourseId = await _dataSource.readLastActiveCourseId();
    final lastLessonId = await _dataSource.readLastActiveLessonId();

    return LearningProgressState(
      completedLessonIds: completedList.toSet(),
      lastActiveCourseId: lastCourseId,
      lastActiveLessonId: lastLessonId,
    );
  }

  @override
  Future<Set<String>> getCompletedLessonIds() async {
    final ids = await _dataSource.readCompletedLessonIds();
    return ids.toSet();
  }

  @override
  Future<LearningProgressState> setLastActiveCourse(String courseId) async {
    await _dataSource.saveLastActiveCourseId(courseId);
    final completedList = await _dataSource.readCompletedLessonIds();
    final lastLessonId = await _dataSource.readLastActiveLessonId();

    return LearningProgressState(
      completedLessonIds: completedList.toSet(),
      lastActiveCourseId: courseId,
      lastActiveLessonId: lastLessonId,
    );
  }

  @override
  Future<LearningProgressState> setLastActiveLesson({
    required String courseId,
    required String lessonId,
  }) async {
    await _dataSource.saveLastActiveCourseId(courseId);
    await _dataSource.saveLastActiveLessonId(lessonId);
    final completedList = await _dataSource.readCompletedLessonIds();

    return LearningProgressState(
      completedLessonIds: completedList.toSet(),
      lastActiveCourseId: courseId,
      lastActiveLessonId: lessonId,
    );
  }

  @override
  Future<LearningProgressState> markLessonCompleted(String lessonId) async {
    final currentIds = (await _dataSource.readCompletedLessonIds()).toSet();
    if (!currentIds.contains(lessonId)) {
      currentIds.add(lessonId);
      await _dataSource.saveCompletedLessonIds(currentIds.toList());
    }

    final lastCourseId = await _dataSource.readLastActiveCourseId();
    final lastLessonId = await _dataSource.readLastActiveLessonId();

    return LearningProgressState(
      completedLessonIds: currentIds,
      lastActiveCourseId: lastCourseId,
      lastActiveLessonId: lastLessonId,
    );
  }

  @override
  Future<LearningProgressState> toggleLessonCompleted(String lessonId) async {
    final currentIds = (await _dataSource.readCompletedLessonIds()).toSet();
    if (currentIds.contains(lessonId)) {
      currentIds.remove(lessonId);
    } else {
      currentIds.add(lessonId);
    }

    await _dataSource.saveCompletedLessonIds(currentIds.toList());
    final lastCourseId = await _dataSource.readLastActiveCourseId();
    final lastLessonId = await _dataSource.readLastActiveLessonId();

    return LearningProgressState(
      completedLessonIds: currentIds,
      lastActiveCourseId: lastCourseId,
      lastActiveLessonId: lastLessonId,
    );
  }
}
