/// Entity immutable yang merepresentasikan materi pembelajaran (lesson).
///
/// Dibuat murni menggunakan Dart SDK tanpa dependensi Flutter.
final class LessonEntity {
  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.videoUrl,
  });

  final String id;
  final String courseId;
  final int order;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          courseId == other.courseId &&
          order == other.order &&
          title == other.title &&
          description == other.description &&
          durationSeconds == other.durationSeconds &&
          videoUrl == other.videoUrl;

  @override
  int get hashCode => Object.hash(
        id,
        courseId,
        order,
        title,
        description,
        durationSeconds,
        videoUrl,
      );

  @override
  String toString() =>
      'LessonEntity(id: $id, courseId: $courseId, order: $order, title: $title)';
}
