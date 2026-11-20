import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_shimmer.dart';

/// Placeholder skeleton untuk [CourseCard] yang memiliki dimensi, padding,
/// border radius, dan rasio proporsi identik dengan kartu aslinya.
class CourseCardSkeleton extends StatelessWidget {
  const CourseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Thumbnail 16:9 dengan placeholder badge kategori & level
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  const SkeletonBox(
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: BorderRadius.zero,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: SkeletonBox(
                      width: 110,
                      height: 24,
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: SkeletonBox(
                      width: 84,
                      height: 24,
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Konten kartu (Padding sama persis 16dp)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul kursus (1 baris panjang)
                  FractionallySizedBox(
                    widthFactor: 0.78,
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(
                      width: double.infinity,
                      height: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Deskripsi singkat (2 baris)
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FractionallySizedBox(
                    widthFactor: 0.68,
                    alignment: Alignment.centerLeft,
                    child: SkeletonBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Linear Progress Bar placeholder
                  SkeletonBox(
                    width: double.infinity,
                    height: 6,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 6),

                  // Baris metadata progres (kiri dan kanan)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(
                        width: 110,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SkeletonBox(
                        width: 30,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Divider konsisten
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 8),

                  // Metadata bawah (Instruktur & Durasi)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(
                        width: 105,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SkeletonBox(
                        width: 68,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
