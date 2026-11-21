import '../entities/learning_progress_state.dart';

abstract interface class ProgressRepository {
  Future<LearningProgressState> getProgressState();

  Future<Set<String>> getCompletedLessonIds();

  Future<LearningProgressState> setLastActiveCourse(String courseId);
  Future<LearningProgressState> setLastActiveLesson({
    required String courseId,
    required String lessonId,
  });

  Future<LearningProgressState> markLessonCompleted(String lessonId);
  Future<LearningProgressState> toggleLessonCompleted(String lessonId);
}
