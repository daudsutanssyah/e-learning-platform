import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../lesson/presentation/widgets/lesson_tile.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../providers/course_providers.dart';

/// Layar detail kursus beserta silabus materi pembelajaran dan indikator progres.
class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressNotifierProvider.notifier)
          .recordCourseOpened(widget.courseId);
    });
  }

  @override
  void didUpdateWidget(covariant CourseDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(progressNotifierProvider.notifier)
            .recordCourseOpened(widget.courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final completedIds = ref.watch(completedLessonIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kursus'),
      ),
      body: courseAsync.when(
        loading: () => const AppLoadingView(
          message: 'Memuat informasi kursus...',
        ),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
        ),
        data: (course) {
          final hasLessons = course.lessons.isNotEmpty;
          final progress = ref.watch(courseProgressProvider(course));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Thumbnail 16:9
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: AppNetworkImage(
                    imageUrl: course.thumbnailUrl,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),

                // Baris badge kategori dan level
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.category,
                        style: const TextStyle(
                          color: AppColors.categoryBadgeText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.levelBadgeBg(course.level),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.level,
                        style: TextStyle(
                          color: AppColors.levelBadgeText(course.level),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Judul Kursus
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Metadata Instruktur, Jumlah Materi, dan Durasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetaItem(
                        icon: Icons.person_rounded,
                        label: 'Instruktur',
                        value: course.instructor,
                      ),
                      _buildMetaDivider(),
                      _buildMetaItem(
                        icon: Icons.play_lesson_rounded,
                        label: 'Materi',
                        value: '${course.lessonCount} Video',
                      ),
                      _buildMetaDivider(),
                      _buildMetaItem(
                        icon: Icons.schedule_rounded,
                        label: 'Total Durasi',
                        value: DurationFormatter.toReadableTotal(
                          course.totalDurationSeconds,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol CTA
                if (hasLessons) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // Cari materi pertama yang belum selesai, atau mulai dari awal
                        final targetLesson = course.lessons.firstWhere(
                          (l) => !completedIds.contains(l.id),
                          orElse: () => course.lessons.first,
                        );
                        context.push(
                          AppRoutes.lessonPlayer(course.id, targetLesson.id),
                        );
                      },
                      icon: Icon(
                        progress.isCompleted
                            ? Icons.replay_rounded
                            : progress.isInProgress
                                ? Icons.play_arrow_rounded
                                : Icons.play_arrow_rounded,
                        size: 22,
                      ),
                      label: Text(
                        progress.isCompleted
                            ? 'Ulangi Belajar'
                            : progress.isInProgress
                                ? 'Lanjutkan Belajar'
                                : 'Mulai Belajar',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Card Ringkasan Progres Kursus
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                progress.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.trending_up_rounded,
                                color: progress.isCompleted
                                    ? AppColors.success
                                    : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                progress.isCompleted
                                    ? 'Kursus Selesai!'
                                    : 'Progres Pembelajaran',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: progress.isCompleted
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${progress.percentageInt}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: progress.isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.percentage,
                          minHeight: 6,
                          backgroundColor:
                              AppColors.outline.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress.isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${progress.completedCount} dari ${progress.totalCount} materi telah diselesaikan',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Deskripsi Lengkap
                const Text(
                  'Tentang Kursus Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Section Silabus Materi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Silabus Pembelajaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${course.lessonCount} Materi',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Daftar Lesson
                if (!hasLessons)
                  const AppEmptyView(
                    title: 'Materi Belum Tersedia',
                    description: 'Silabus kursus ini sedang dalam persiapan.',
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: course.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = course.lessons[index];
                      final isCompleted = completedIds.contains(lesson.id);

                      return LessonTile(
                        lesson: lesson,
                        isActive: false,
                        isCompleted: isCompleted,
                        onTap: () => context.push(
                          AppRoutes.lessonPlayer(course.id, lesson.id),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDivider() {
    return Container(
      height: 28,
      width: 1,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
