import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/progress_providers.dart';

/// Baris filter status kursus (Semua, Sedang Dipelajari, Selesai) berbasis [ChoiceChip].
class CourseFilterBar extends ConsumerWidget {
  const CourseFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(courseFilterProvider);
    final counts = ref.watch(courseFilterCountsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context: context,
            ref: ref,
            status: CourseFilterStatus.all,
            label: 'Semua',
            count: counts.all,
            isSelected: activeFilter == CourseFilterStatus.all,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            ref: ref,
            status: CourseFilterStatus.inProgress,
            label: 'Sedang Dipelajari',
            count: counts.inProgress,
            isSelected: activeFilter == CourseFilterStatus.inProgress,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            ref: ref,
            status: CourseFilterStatus.completed,
            label: 'Selesai',
            count: counts.completed,
            isSelected: activeFilter == CourseFilterStatus.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required WidgetRef ref,
    required CourseFilterStatus status,
    required String label,
    required int count,
    required bool isSelected,
  }) {
    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(courseFilterProvider.notifier).setFilter(status);
        }
      },
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      selectedColor: AppColors.primaryContainer,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.outline,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }
}
