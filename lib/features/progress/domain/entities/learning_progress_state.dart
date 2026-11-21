import 'package:flutter/foundation.dart';

@immutable
final class LearningProgressState {
  const LearningProgressState({
    this.completedLessonIds = const <String>{},
    this.lastActiveCourseId,
    this.lastActiveLessonId,
  });

  final Set<String> completedLessonIds;

  final String? lastActiveCourseId;

  final String? lastActiveLessonId;

  LearningProgressState copyWith({
    Set<String>? completedLessonIds,
    String? Function()? lastActiveCourseId,
    String? Function()? lastActiveLessonId,
  }) {
    return LearningProgressState(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lastActiveCourseId: lastActiveCourseId != null
          ? lastActiveCourseId()
          : this.lastActiveCourseId,
      lastActiveLessonId: lastActiveLessonId != null
          ? lastActiveLessonId()
          : this.lastActiveLessonId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningProgressState &&
          runtimeType == other.runtimeType &&
          setEquals(completedLessonIds, other.completedLessonIds) &&
          lastActiveCourseId == other.lastActiveCourseId &&
          lastActiveLessonId == other.lastActiveLessonId;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(completedLessonIds),
    lastActiveCourseId,
    lastActiveLessonId,
  );

  @override
  String toString() =>
      'LearningProgressState(completedLessons: ${completedLessonIds.length}, '
      'lastActiveCourseId: $lastActiveCourseId, lastActiveLessonId: $lastActiveLessonId)';
}
