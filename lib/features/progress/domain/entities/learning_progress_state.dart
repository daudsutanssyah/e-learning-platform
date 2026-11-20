import 'package:flutter/foundation.dart';

/// Entitas domain immutable yang menyimpan status progres belajar lokal pengguna,
/// mencakup himpunan materi yang telah selesai serta riwayat kelas dan materi terakhir dibuka.
@immutable
final class LearningProgressState {
  const LearningProgressState({
    this.completedLessonIds = const <String>{},
    this.lastActiveCourseId,
    this.lastActiveLessonId,
  });

  /// Kumpulan ID materi yang telah diselesaikan.
  final Set<String> completedLessonIds;

  /// ID kursus yang terakhir kali dibuka oleh pengguna.
  final String? lastActiveCourseId;

  /// ID materi yang terakhir kali dibuka atau dipelajari oleh pengguna.
  final String? lastActiveLessonId;

  /// Membuat salinan objek dengan field yang diperbarui secara opsional.
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
