import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idile_mobile_app/core/theme/app_theme.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';
import 'package:idile_mobile_app/shared/widgets/input.dart';

void main() {
  testWidgets('shared AppText component renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppText.raw('Ìdílé'))),
    );

    expect(find.text('Ìdílé'), findsOneWidget);
  });

  testWidgets('password visibility persists after parent rebuild', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _PasswordFieldHost()));

    EditableText field() => tester.widget(find.byType(EditableText));

    expect(field().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(field().obscureText, isFalse);

    await tester.enterText(find.byType(TextFormField), 'password123');
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('shared inputs render and select in ${mode.name} mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const _InputThemeHost(),
        ),
      );

      final context = tester.element(find.byType(GlobalTextField));
      final expectedColor = Theme.of(context).colorScheme.onSurface;
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.style.color, expectedColor);

      final selectedLabel = tester.widget<AppText>(
        find.byWidgetPredicate(
          (widget) => widget is AppText && widget.text == 'Home',
        ),
      );
      expect(selectedLabel.color, expectedColor);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Office'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shared buttons use accessible colors in ${mode.name} mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: const _ButtonThemeHost(),
        ),
      );

      final context = tester.element(find.byKey(const Key('logout-button')));
      final colors = Theme.of(context).colorScheme;

      AppText labelFor(String key) => tester.widget<AppText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(AppText),
        ),
      );

      BoxDecoration decorationFor(String key) =>
          tester
                  .widget<DecoratedBox>(
                    find
                        .descendant(
                          of: find.byKey(Key(key)),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;

      expect(labelFor('logout-button').color, colors.onSurface);
      expect(
        labelFor('legacy-filled-button').color,
        mode == ThemeMode.dark ? colors.onPrimary : AppColors.signal,
      );
      expect(decorationFor('legacy-filled-button').color, colors.primary);
      expect(labelFor('disabled-button').color, colors.onSurfaceVariant);
      expect(
        decorationFor('disabled-button').color,
        colors.surfaceContainerHighest,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('compact button centers its icon and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const _ButtonThemeHost()),
    );

    final button = find.byKey(const Key('compact-icon-button'));
    final background = find
        .descendant(of: button, matching: find.byType(DecoratedBox))
        .first;
    final icon = find.descendant(
      of: button,
      matching: find.byKey(const Key('compact-button-icon')),
    );
    final label = find.descendant(of: button, matching: find.text('Revoke'));

    final buttonRect = tester.getRect(background);
    final iconRect = tester.getRect(icon);
    final labelRect = tester.getRect(label);
    final contentLeft = iconRect.left < labelRect.left
        ? iconRect.left
        : labelRect.left;
    final contentRight = iconRect.right > labelRect.right
        ? iconRect.right
        : labelRect.right;
    final contentCenterX = (contentLeft + contentRight) / 2;

    expect(contentCenterX, closeTo(buttonRect.center.dx, 0.5));
    expect(iconRect.center.dy, closeTo(buttonRect.center.dy, 0.5));
    expect(labelRect.center.dy, closeTo(buttonRect.center.dy, 0.5));
  });
}

class _ButtonThemeHost extends StatelessWidget {
  const _ButtonThemeHost();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Column(
        children: [
          AppButton(
            key: const Key('logout-button'),
            text: 'Sign out',
            onPressed: () {},
            icon: const Icon(Icons.logout),
            variant: AppButtonVariant.outlined,
          ),
          AppButton(
            key: const Key('legacy-filled-button'),
            text: 'Add item',
            onPressed: () {},
            btnColor: AppColors.ink,
            textColor: AppColors.signal,
          ),
          const AppButton(
            key: Key('disabled-button'),
            text: 'Submit',
            onPressed: null,
          ),
          AppButton(
            key: const Key('compact-icon-button'),
            text: 'Revoke',
            onPressed: () {},
            icon: const Icon(
              Icons.block_outlined,
              key: Key('compact-button-icon'),
            ),
            variant: AppButtonVariant.outlined,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _InputThemeHost extends StatefulWidget {
  const _InputThemeHost();

  @override
  State<_InputThemeHost> createState() => _InputThemeHostState();
}

class _InputThemeHostState extends State<_InputThemeHost> {
  final controller = TextEditingController();
  String place = 'home';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlobalTextField(
              fieldName: 'Name',
              keyBoardType: TextInputType.name,
              textController: controller,
            ),
            const SizedBox(height: 16),
            GlobalSearchableDropdown<String>(
              title: 'Place',
              value: place,
              options: const [
                SearchableDropdownOption(value: 'home', label: 'Home'),
                SearchableDropdownOption(value: 'office', label: 'Office'),
              ],
              onChanged: (value) => setState(() => place = value),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordFieldHost extends StatefulWidget {
  const _PasswordFieldHost();

  @override
  State<_PasswordFieldHost> createState() => _PasswordFieldHostState();
}

class _PasswordFieldHostState extends State<_PasswordFieldHost> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      body: GlobalTextField(
        fieldName: 'Password',
        keyBoardType: TextInputType.visiblePassword,
        textController: controller,
        obscureText: true,
        isEyeVisible: true,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
