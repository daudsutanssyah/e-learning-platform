import '../../../../core/errors/failures.dart';
import '../../../lesson/data/models/lesson_model.dart';
import '../../domain/entities/course_entity.dart';

/// Data model untuk entitas Course dengan serialisasi dan parsing JSON defensif.
final class CourseModel {
  const CourseModel({
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

  /// Factory untuk membuat [CourseModel] dari map JSON dengan validasi defensif.
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "id" pada Course tidak valid atau kosong.',
      );
    }

    final title = json['title'];
    if (title is! String || title.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "title" pada Course tidak valid atau kosong.',
      );
    }

    final shortDescription = json['short_description'];
    if (shortDescription is! String) {
      throw const DataParsingFailure(
        'Field "short_description" pada Course harus bertipe string.',
      );
    }

    final description = json['description'];
    if (description is! String) {
      throw const DataParsingFailure(
        'Field "description" pada Course harus bertipe string.',
      );
    }

    final category = json['category'];
    if (category is! String || category.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "category" pada Course tidak valid atau kosong.',
      );
    }

    final level = json['level'];
    if (level is! String || level.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "level" pada Course tidak valid atau kosong.',
      );
    }

    final instructor = json['instructor'];
    if (instructor is! String || instructor.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "instructor" pada Course tidak valid atau kosong.',
      );
    }

    final thumbnailUrl = json['thumbnail_url'];
    if (thumbnailUrl is! String || thumbnailUrl.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "thumbnail_url" pada Course tidak valid atau kosong.',
      );
    }

    final rawTotalDuration = json['total_duration_seconds'];
    if (rawTotalDuration is! num) {
      throw const DataParsingFailure(
        'Field "total_duration_seconds" pada Course harus berupa angka numerik.',
      );
    }
    final totalDurationSeconds = rawTotalDuration.toInt();

    final rawLessons = json['lessons'];
    if (rawLessons is! List) {
      throw const DataParsingFailure(
        'Field "lessons" pada Course harus berupa list JSON.',
      );
    }

    final parsedLessons = <LessonModel>[];
    for (final rawLesson in rawLessons) {
      if (rawLesson is! Map<String, dynamic>) {
        throw const DataParsingFailure(
          'Setiap item lesson pada Course harus berupa objek JSON.',
        );
      }
      parsedLessons.add(LessonModel.fromJson(rawLesson));
    }

    parsedLessons.sort((a, b) => a.order.compareTo(b.order));

    return CourseModel(
      id: id,
      title: title,
      shortDescription: shortDescription,
      description: description,
      category: category,
      level: level,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl,
      totalDurationSeconds: totalDurationSeconds,
      lessons: parsedLessons,
    );
  }

  final String id;
  final String title;
  final String shortDescription;
  final String description;
  final String category;
  final String level;
  final String instructor;
  final String thumbnailUrl;
  final int totalDurationSeconds;
  final List<LessonModel> lessons;

  /// Mengonversi model ke format JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'short_description': shortDescription,
        'description': description,
        'category': category,
        'level': level,
        'instructor': instructor,
        'thumbnail_url': thumbnailUrl,
        'total_duration_seconds': totalDurationSeconds,
        'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      };

  /// Mengonversi model data ke [CourseEntity] domain dengan daftar materi immutable.
  CourseEntity toEntity() => CourseEntity(
        id: id,
        title: title,
        shortDescription: shortDescription,
        description: description,
        category: category,
        level: level,
        instructor: instructor,
        thumbnailUrl: thumbnailUrl,
        totalDurationSeconds: totalDurationSeconds,
        lessons: List.unmodifiable(
          lessons.map((lesson) => lesson.toEntity()),
        ),
      );

  static bool _areLessonsEqual(List<LessonModel> a, List<LessonModel> b) {
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
      other is CourseModel &&
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
      'CourseModel(id: $id, title: $title, lessonsCount: ${lessons.length})';
}
