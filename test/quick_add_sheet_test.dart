import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/features/home/presentation/widget/quick_add/quick_add_sheet.dart';

void main() {
  testWidgets('quick-add sheet does not overflow on a compact screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    QuickAddType? selection;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            SizeConfig.init(context);
            return Scaffold(
              body: Center(
                child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    selection = await showQuickAddSheet(context);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add something new'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Asset'));
    await tester.pumpAndSettle();
    expect(selection, QuickAddType.asset);
  });
}
