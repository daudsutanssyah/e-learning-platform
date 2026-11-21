import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';
import 'course_card_skeleton.dart';

class CourseListSkeleton extends StatelessWidget {
  const CourseListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Placeholder LearningSummaryCard
            _buildSummaryCardSkeleton(),
            const SizedBox(height: 16),

            // 2. Placeholder CourseFilterBar
            _buildFilterBarSkeleton(),
            const SizedBox(height: 16),

            // 3. Tiga item CourseCardSkeleton
            const CourseCardSkeleton(),
            const SizedBox(height: 16),
            const CourseCardSkeleton(),
            const SizedBox(height: 16),
            const CourseCardSkeleton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Badge kiri & Persentase kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(
                width: 140,
                height: 24,
                borderRadius: BorderRadius.circular(6),
              ),
              SkeletonBox(
                width: 52,
                height: 26,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Judul kursus aktif
          FractionallySizedBox(
            widthFactor: 0.72,
            alignment: Alignment.centerLeft,
            child: SkeletonBox(
              width: double.infinity,
              height: 18,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Linear Progress Bar
          SkeletonBox(
            width: double.infinity,
            height: 7,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 10),

          // Metadata materi & lanjutan
          Row(
            children: [
              SkeletonBox(
                width: 90,
                height: 20,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkeletonBox(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol aksi
          SkeletonBox(
            width: double.infinity,
            height: 38,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBarSkeleton() {
    return Row(
      children: [
        SkeletonBox(
          width: 84,
          height: 34,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(width: 8),
        SkeletonBox(
          width: 142,
          height: 34,
          borderRadius: BorderRadius.circular(20),
        ),
        const SizedBox(width: 8),
        SkeletonBox(
          width: 90,
          height: 34,
          borderRadius: BorderRadius.circular(20),
        ),
      ],
    );
  }
}
