import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/core/theme/app_theme.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/home/presentation/widget/dashboard/home_empty_state.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('renders the empty Home state in ${mode.name} mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: Builder(
            builder: (context) {
              SizeConfig.init(context);
              return Scaffold(
                body: HomeEmptyState(
                  name: 'John Paul',
                  now: DateTime(2026, 10, 7, 15, 30),
                  onRefresh: () async {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('home-empty-state')), findsOneWidget);
      expect(find.text('GOOD AFTERNOON,\nJOHN PAUL'), findsOneWidget);
      expect(find.text('Wednesday 7 October'), findsOneWidget);
      expect(find.text('Your space is ready when you are'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
