final class CourseProgressEntity {
  const CourseProgressEntity({
    required this.completedCount,
    required this.totalCount,
  });

  /// Jumlah materi yang telah diselesaikan.
  final int completedCount;

  /// Jumlah total materi yang ada pada kursus.
  final int totalCount;

  /// Persentase progres dalam rentang `0.0` sampai `1.0`.
  double get percentage =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  /// Persentase progres dalam bilangan bulat bulat (`0` sampai `100`).
  int get percentageInt => (percentage * 100).round();

  bool get isCompleted => totalCount > 0 && completedCount >= totalCount;

  bool get isInProgress => completedCount > 0 && !isCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseProgressEntity &&
          runtimeType == other.runtimeType &&
          completedCount == other.completedCount &&
          totalCount == other.totalCount;

  @override
  int get hashCode => Object.hash(completedCount, totalCount);

  @override
  String toString() =>
      'CourseProgressEntity(completed: $completedCount/$totalCount, percentage: $percentageInt%)';
}
