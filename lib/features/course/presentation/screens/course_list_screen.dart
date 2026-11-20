import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../progress/presentation/widgets/course_filter_bar.dart';
import '../../../progress/presentation/widgets/learning_summary_card.dart';
import '../providers/course_providers.dart';
import '../widgets/course_card.dart';
import '../widgets/course_list_skeleton.dart';

/// Layar katalog utama kursus pembelajaran dilengkapi ringkasan progres dan filter status.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesListProvider);
    final filteredCourses = ref.watch(filteredCoursesProvider);
    final activeFilter = ref.watch(courseFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(width: 10),
            Text('E-Learning Platform'),
          ],
        ),
      ),
      body: coursesAsync.when(
        loading: () => const CourseListSkeleton(),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.invalidate(coursesListProvider),
        ),
        data: (courses) {
          if (courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(coursesListProvider.future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: AppEmptyView(
                      title: 'Katalog Kursus Kosong',
                      description:
                          'Saat ini belum ada materi kursus yang tersedia untuk dipelajari.',
                      actionLabel: 'Segarkan Halaman',
                      onAction: () => ref.refresh(coursesListProvider.future),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(coursesListProvider.future),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth >= 600;

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Ringkasan Belajar & Filter Bar
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LearningSummaryCard(),
                            SizedBox(height: 16),
                            CourseFilterBar(),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Konten Daftar Kursus / Filter Empty State
                    if (filteredCourses.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: _buildFilterEmptyState(
                            context,
                            ref,
                            activeFilter,
                          ),
                        ),
                      )
                    else if (isWideScreen)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final course = filteredCourses[index];
                              return CourseCard(
                                course: course,
                                onTap: () => context.push(
                                  AppRoutes.courseDetail(course.id),
                                ),
                              );
                            },
                            childCount: filteredCourses.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final course = filteredCourses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CourseCard(
                                  course: course,
                                  onTap: () => context.push(
                                    AppRoutes.courseDetail(course.id),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredCourses.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterEmptyState(
    BuildContext context,
    WidgetRef ref,
    CourseFilterStatus filter,
  ) {
    final String title;
    final String desc;
    final IconData icon;

    switch (filter) {
      case CourseFilterStatus.inProgress:
        icon = Icons.hourglass_empty_rounded;
        title = 'Belum Ada Kursus yang Sedang Dipelajari';
        desc =
            'Pilih salah satu kursus dan mulai tonton materi pertamamu untuk mencatat progres.';
      case CourseFilterStatus.completed:
        icon = Icons.fact_check_outlined;
        title = 'Belum Ada Kursus yang Selesai';
        desc =
            'Selesaikan seluruh materi pada kursus untuk melihat daftar kursus tuntas di sini.';
      case CourseFilterStatus.all:
        icon = Icons.search_off_rounded;
        title = 'Tidak Ada Kursus Ditemukan';
        desc = 'Tidak ada kursus yang sesuai dengan kriteria penyaringan saat ini.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              ref
                  .read(courseFilterProvider.notifier)
                  .setFilter(CourseFilterStatus.all);
            },
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const Text('Tampilkan Semua Kursus'),
          ),
        ],
      ),
    );
  }
}
