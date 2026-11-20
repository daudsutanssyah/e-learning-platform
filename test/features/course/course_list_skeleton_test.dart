import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:e_learning_platform/core/widgets/skeleton_shimmer.dart';
import 'package:e_learning_platform/features/course/presentation/widgets/course_card_skeleton.dart';
import 'package:e_learning_platform/features/course/presentation/widgets/course_list_skeleton.dart';

void main() {
  group('Skeleton Shimmer & CourseListSkeleton Tests', () {
    testWidgets('CourseCardSkeleton renders properly within ExcludeSemantics',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: CourseCardSkeleton(),
            ),
          ),
        ),
      );

      // Gunakan pump untuk memajukan frame awal tanpa menunggu repeat() selesai
      await tester.pump();

      expect(find.byType(CourseCardSkeleton), findsOneWidget);
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets(
        'CourseListSkeleton renders summary, filter, and 3 card skeletons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CourseListSkeleton(),
          ),
        ),
      );

      // Verifikasi rendering awal skeleton
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CourseListSkeleton), findsOneWidget);
      expect(find.byType(SkeletonShimmer), findsOneWidget);
      expect(find.byType(CourseCardSkeleton), findsNWidgets(3));
    });

    testWidgets(
        'SkeletonShimmer respects MediaQuery.disableAnimations (no crash)',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: SkeletonShimmer(
                child: SkeletonBox(width: 100, height: 20),
              ),
            ),
          ),
        ),
      );

      // Dengan animasi dimatikan, pumpAndSettle dapat selesai secara instan
      await tester.pumpAndSettle();

      expect(find.byType(SkeletonBox), findsOneWidget);
    });
  });
}
