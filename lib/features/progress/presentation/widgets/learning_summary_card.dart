import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/resolve_active_course_use_case.dart';
import '../providers/progress_providers.dart';

/// Kartu ringkasan belajar kontekstual berbasis kelas aktif dengan 3 state tampilan:
/// 1. Sambutan Awal (Cold Start: belum ada kelas aktif).
/// 2. Kelas Aktif (sedang dalam proses belajar).
/// 3. Kelas Aktif Tuntas (100% selesai).
class LearningSummaryCard extends ConsumerWidget {
  const LearningSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolution = ref.watch(activeCourseResolutionProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleCardTap(context, resolution),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: _buildContent(context, resolution),
          ),
        ),
      ),
    );
  }

  void _handleCardTap(
    BuildContext context,
    ActiveCourseResolution resolution,
  ) {
    if (resolution.isColdStart) {
      if (resolution.recommendedFirstCourse != null) {
        context.push(
          AppRoutes.courseDetail(resolution.recommendedFirstCourse!.id),
        );
      }
    } else if (resolution.isInProgress) {
      if (resolution.nextLesson != null) {
        context.push(
          AppRoutes.lessonPlayer(
            resolution.activeCourse!.id,
            resolution.nextLesson!.id,
          ),
        );
      } else {
        context.push(
          AppRoutes.courseDetail(resolution.activeCourse!.id),
        );
      }
    } else if (resolution.isCompleted) {
      if (resolution.nextRecommendedCourse != null) {
        context.push(
          AppRoutes.courseDetail(resolution.nextRecommendedCourse!.id),
        );
      } else {
        context.push(
          AppRoutes.courseDetail(resolution.activeCourse!.id),
        );
      }
    }
  }

  Widget _buildContent(
    BuildContext context,
    ActiveCourseResolution resolution,
  ) {
    if (resolution.isColdStart) {
      return _buildColdStartState(context, resolution);
    } else if (resolution.isCompleted) {
      return _buildCompletedState(context, resolution);
    } else {
      return _buildInProgressState(context, resolution);
    }
  }

  // ==========================================
  // STATE 1: SAMBUTAN AWAL (COLD START)
  // ==========================================
  Widget _buildColdStartState(
    BuildContext context,
    ActiveCourseResolution resolution,
  ) {
    final firstCourse = resolution.recommendedFirstCourse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Siap Mulai Belajar?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Pilih materi pertamamu dan tingkatkan keahlian baru hari ini.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: 12,
            height: 1.35,
          ),
        ),
        if (firstCourse != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Pertama',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        firstCourse.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${firstCourse.lessonCount} Materi',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => context.push(
                AppRoutes.courseDetail(firstCourse.id),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text(
                'Mulai Belajar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================
  // STATE 2: KELAS AKTIF (IN-PROGRESS)
  // ==========================================
  Widget _buildInProgressState(
    BuildContext context,
    ActiveCourseResolution resolution,
  ) {
    final activeCourse = resolution.activeCourse!;
    final progress = resolution.activeCourseProgress!;
    final nextLesson = resolution.nextLesson;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Header: Badge Status & Persentase Kelas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Sedang Dipelajari',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${progress.percentageInt}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Judul Kelas Aktif (Maks 2 Baris)
        Text(
          activeCourse.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),

        // Linear Progress Bar Kelas Aktif
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.percentage,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        // Label Rasio Materi & Info Materi Lanjutan
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${progress.completedCount}/${progress.totalCount} Materi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (nextLesson != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Berikutnya: ${nextLesson.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // Tombol Aksi: Lanjutkan Belajar
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (nextLesson != null) {
                context.push(
                  AppRoutes.lessonPlayer(activeCourse.id, nextLesson.id),
                );
              } else {
                context.push(
                  AppRoutes.courseDetail(activeCourse.id),
                );
              }
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text(
              'Lanjutkan Belajar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // STATE 3: KELAS AKTIF TUNTAS (100%)
  // ==========================================
  Widget _buildCompletedState(
    BuildContext context,
    ActiveCourseResolution resolution,
  ) {
    final activeCourse = resolution.activeCourse!;
    final progress = resolution.activeCourseProgress!;
    final nextRecommended = resolution.nextRecommendedCourse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris Header: Badge Kelas Tuntas & 100%
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Kelas Tuntas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              '100%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Judul Kelas Tuntas
        Text(
          activeCourse.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 12),

        // Progress Bar Penuh
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 7,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 10),

        // Label Selesai
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${progress.totalCount}/${progress.totalCount} Materi Selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                nextRecommended != null
                    ? 'Berikutnya: ${nextRecommended.title}'
                    : 'Seluruh materi telah kamu selesaikan!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Tombol Aksi: Lanjut Kelas Berikutnya atau Ulas Materi
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (nextRecommended != null) {
                context.push(
                  AppRoutes.courseDetail(nextRecommended.id),
                );
              } else {
                context.push(
                  AppRoutes.courseDetail(activeCourse.id),
                );
              }
            },
            icon: Icon(
              nextRecommended != null
                  ? Icons.arrow_forward_rounded
                  : Icons.replay_rounded,
              size: 18,
            ),
            label: Text(
              nextRecommended != null
                  ? 'Lanjut Kelas Berikutnya'
                  : 'Ulas Materi',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
