import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_learning_platform/core/services/local_json_service.dart';
import 'package:e_learning_platform/features/course/data/data_sources/course_data_source.dart';
import 'package:e_learning_platform/features/course/presentation/providers/course_providers.dart';
import 'package:e_learning_platform/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ELearningApp renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseDataSourceProvider.overrideWithValue(
            MockCourseDataSource(
              LocalJsonService(simulatedDelay: Duration.zero),
            ),
          ),
        ],
        child: const ELearningApp(),
      ),
    );

    // Biarkan seluruh future dan frame diselesaikan
    await tester.pumpAndSettle();

    // Memverifikasi widget root aplikasi berhasil di-render
    expect(find.byType(ELearningApp), findsOneWidget);
  });
}
