/// Entitas domain immutable yang merepresentasikan progres pembelajaran keseluruhan akun/perangkat.
final class OverallProgressEntity {
  const OverallProgressEntity({
    required this.completedLessonsCount,
    required this.totalLessonsCount,
    required this.completedCoursesCount,
    required this.totalCoursesCount,
  });

  /// Jumlah seluruh materi yang telah diselesaikan di semua kursus.
  final int completedLessonsCount;

  /// Jumlah total materi di seluruh kursus.
  final int totalLessonsCount;

  /// Jumlah kursus yang seluruh materinya telah selesai.
  final int completedCoursesCount;

  /// Jumlah total kursus yang tersedia.
  final int totalCoursesCount;

  /// Persentase materi selesai secara keseluruhan dalam rentang `0.0` sampai `1.0`.
  double get percentage => totalLessonsCount == 0
      ? 0.0
      : (completedLessonsCount / totalLessonsCount).clamp(0.0, 1.0);

  /// Persentase materi selesai secara keseluruhan dalam bilangan bulat bulat (`0` sampai `100`).
  int get percentageInt => (percentage * 100).round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverallProgressEntity &&
          runtimeType == other.runtimeType &&
          completedLessonsCount == other.completedLessonsCount &&
          totalLessonsCount == other.totalLessonsCount &&
          completedCoursesCount == other.completedCoursesCount &&
          totalCoursesCount == other.totalCoursesCount;

  @override
  int get hashCode => Object.hash(
        completedLessonsCount,
        totalLessonsCount,
        completedCoursesCount,
        totalCoursesCount,
      );

  @override
  String toString() =>
      'OverallProgressEntity(lessons: $completedLessonsCount/$totalLessonsCount, '
      'courses: $completedCoursesCount/$totalCoursesCount, percentage: $percentageInt%)';
}
