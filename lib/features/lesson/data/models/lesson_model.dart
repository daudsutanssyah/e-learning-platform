import '../../../../core/errors/failures.dart';
import '../../domain/entities/lesson_entity.dart';

/// Data model untuk entitas Lesson dengan serialisasi JSON yang aman.
final class LessonModel {
  const LessonModel({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    required this.description,
    required this.durationSeconds,
    required this.videoUrl,
  });

  /// Factory untuk membuat [LessonModel] dari map JSON dengan validasi defensif.
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "id" pada Lesson tidak valid atau kosong.',
      );
    }

    final courseId = json['course_id'];
    if (courseId is! String || courseId.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "course_id" pada Lesson tidak valid atau kosong.',
      );
    }

    final rawOrder = json['order'];
    if (rawOrder is! num) {
      throw const DataParsingFailure(
        'Field "order" pada Lesson harus berupa angka numerik.',
      );
    }
    final order = rawOrder.toInt();

    final title = json['title'];
    if (title is! String || title.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "title" pada Lesson tidak valid atau kosong.',
      );
    }

    final description = json['description'];
    if (description is! String) {
      throw const DataParsingFailure(
        'Field "description" pada Lesson harus bertipe string.',
      );
    }

    final rawDuration = json['duration_seconds'];
    if (rawDuration is! num) {
      throw const DataParsingFailure(
        'Field "duration_seconds" pada Lesson harus berupa angka numerik.',
      );
    }
    final durationSeconds = rawDuration.toInt();

    final videoUrl = json['video_url'];
    if (videoUrl is! String || videoUrl.trim().isEmpty) {
      throw const DataParsingFailure(
        'Field "video_url" pada Lesson tidak valid atau kosong.',
      );
    }

    return LessonModel(
      id: id,
      courseId: courseId,
      order: order,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
      videoUrl: videoUrl,
    );
  }

  final String id;
  final String courseId;
  final int order;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;

  /// Mengonversi model ke format JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'order': order,
        'title': title,
        'description': description,
        'duration_seconds': durationSeconds,
        'video_url': videoUrl,
      };

  /// Mengonversi model data ke [LessonEntity] domain.
  LessonEntity toEntity() => LessonEntity(
        id: id,
        courseId: courseId,
        order: order,
        title: title,
        description: description,
        durationSeconds: durationSeconds,
        videoUrl: videoUrl,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonModel &&
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
      'LessonModel(id: $id, courseId: $courseId, order: $order, title: $title)';
}
