import '../../../lesson/domain/entities/lesson_entity.dart';

/// Entity immutable yang merepresentasikan kursus pembelajaran.
///
/// Dibuat murni menggunakan Dart SDK tanpa dependensi framework Flutter.
final class CourseEntity {
  const CourseEntity({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.category,
    required this.level,
    required this.instructor,
    required this.thumbnailUrl,
    required this.totalDurationSeconds,
    required this.lessons,
  });

  final String id;
  final String title;
  final String shortDescription;
  final String description;
  final String category;
  final String level;
  final String instructor;
  final String thumbnailUrl;
  final int totalDurationSeconds;
  final List<LessonEntity> lessons;

  /// Jumlah total materi yang tersedia di kursus ini.
  int get lessonCount => lessons.length;

  static bool _areLessonsEqual(List<LessonEntity> a, List<LessonEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          shortDescription == other.shortDescription &&
          description == other.description &&
          category == other.category &&
          level == other.level &&
          instructor == other.instructor &&
          thumbnailUrl == other.thumbnailUrl &&
          totalDurationSeconds == other.totalDurationSeconds &&
          _areLessonsEqual(lessons, other.lessons);

  @override
  int get hashCode => Object.hash(
        id,
        title,
        shortDescription,
        description,
        category,
        level,
        instructor,
        thumbnailUrl,
        totalDurationSeconds,
        Object.hashAll(lessons),
      );

  @override
  String toString() =>
      'CourseEntity(id: $id, title: $title, lessonCount: $lessonCount)';
}
