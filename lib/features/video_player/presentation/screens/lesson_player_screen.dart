import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../course/presentation/providers/course_providers.dart';
import '../../../lesson/presentation/widgets/lesson_tile.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../widgets/chewie_lesson_player.dart';


class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.initialLessonId,
  });

  final String courseId;
  final String initialLessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  late String _activeLessonId;

  @override
  void initState() {
    super.initState();
    _activeLessonId = widget.initialLessonId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(progressNotifierProvider.notifier).recordLessonOpened(
            courseId: widget.courseId,
            lessonId: _activeLessonId,
          );
    });
  }

  @override
  void didUpdateWidget(covariant LessonPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLessonId != widget.initialLessonId ||
        oldWidget.courseId != widget.courseId) {
      setState(() {
        _activeLessonId = widget.initialLessonId;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(progressNotifierProvider.notifier).recordLessonOpened(
              courseId: widget.courseId,
              lessonId: _activeLessonId,
            );
      });
    }
  }

  void _changeLesson(String lessonId) {
    if (_activeLessonId != lessonId) {
      setState(() {
        _activeLessonId = lessonId;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(progressNotifierProvider.notifier).recordLessonOpened(
              courseId: widget.courseId,
              lessonId: lessonId,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final completedIds = ref.watch(completedLessonIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          courseAsync.value?.title ?? 'Pemutar Materi',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.courseDetail(widget.courseId));
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Katalog Kursus',
            icon: const Icon(Icons.home_outlined),
            onPressed: () => context.go(AppRoutes.courseListPath),
          ),
        ],
      ),
      body: courseAsync.when(
        loading: () => const AppLoadingView(
          message: 'Memuat pemutar materi...',
        ),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
        ),
        data: (course) {
          final lessons = course.lessons;
          final activeIndex = lessons.indexWhere((l) => l.id == _activeLessonId);

          if (activeIndex == -1) {
            return const AppErrorView(
              error: NotFoundFailure('Materi pembelajaran tidak ditemukan.'),
            );
          }

          final activeLesson = lessons[activeIndex];
          final isCurrentCompleted = completedIds.contains(activeLesson.id);
          final hasPrevious = activeIndex > 0;
          final hasNext = activeIndex < lessons.length - 1;

          return Column(
            children: [
              // Area Atas: Pemutar Video Native Chewie (Fixed 16:9)
              ChewieLessonPlayer(
                lessonId: activeLesson.id,
                videoUrl: activeLesson.videoUrl,
                onVideoEnded: () {
                  // Tandai materi selesai otomatis saat durasi video tuntas
                  ref
                      .read(progressNotifierProvider.notifier)
                      .markCompleted(activeLesson.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Materi "${activeLesson.title}" selesai dipelajari!',
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  if (hasNext) {
                    _changeLesson(lessons[activeIndex + 1].id);
                  }
                },
              ),

              // Area Bawah: Scrollable Info Materi & Navigasi Silabus
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Materi & Durasi
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Materi ${activeLesson.order} dari ${lessons.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DurationFormatter.toClockFormat(
                              activeLesson.durationSeconds,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Judul Materi
                      Text(
                        activeLesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Deskripsi Materi
                      Text(
                        activeLesson.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Status Penyelesaian Materi (Tandai Selesai / Sudah Selesai)
                      SizedBox(
                        width: double.infinity,
                        child: isCurrentCompleted
                            ? FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(progressNotifierProvider.notifier)
                                      .toggleCompleted(activeLesson.id);
                                },
                                icon: const Icon(
                                  Icons.check_circle_rounded,
                                  size: 18,
                                ),
                                label: const Text('Sudah Selesai (Ketuk untuk Batal)'),
                              )
                            : OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  ref
                                      .read(progressNotifierProvider.notifier)
                                      .markCompleted(activeLesson.id);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Materi berhasil ditandai selesai!',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 18,
                                ),
                                label: const Text('Tandai Selesai'),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Tombol Navigasi Sebelumnya & Berikutnya
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: hasPrevious
                                  ? () => _changeLesson(
                                        lessons[activeIndex - 1].id,
                                      )
                                  : null,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 16,
                              ),
                              label: const Text('Sebelumnya'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: hasNext
                                  ? () => _changeLesson(
                                        lessons[activeIndex + 1].id,
                                      )
                                  : null,
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                              ),
                              label: const Text('Berikutnya'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 16),

                      // Daftar Silabus Materi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Materi Pembelajaran',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${lessons.length} Video',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = lessons[index];
                          final isItemActive = lesson.id == _activeLessonId;
                          final isItemCompleted =
                              completedIds.contains(lesson.id);

                          return LessonTile(
                            lesson: lesson,
                            isActive: isItemActive,
                            isCompleted: isItemCompleted,
                            onTap: () => _changeLesson(lesson.id),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
