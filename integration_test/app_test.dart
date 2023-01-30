import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nwt_reading/main.dart' as app;
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final deepCollectionEquals = const DeepCollectionEquality().equals;
  SharedPreferences.setMockInitialValues({});
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final uncontrolledProviderScope = await app.main();
  final container = uncontrolledProviderScope.container;
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('Entities are initialized', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.pumpAndSettle();

    expect(
        deepCollectionEquals(
            container.read(plansProvider).valueOrNull?.plans, <Plan>[]),
        true);
    expect(container.read(locationsProvider).valueOrNull, isA<Locations>());
    expect(container.read(eventsProvider).valueOrNull, isA<Events>());
    expect(container.read(schedulesProvider).valueOrNull, isA<Schedules>());
    expect(container.read(bibleLanguagesProvider).valueOrNull,
        isA<BibleLanguages>());
    expect(container.read(themeModeProvider).valueOrNull, ThemeMode.system);
  });

  testWidgets('No plans', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });

  testWidgets('Add plans', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(container.read(plansProvider).valueOrNull?.plans.length, 1);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(container.read(plansProvider).valueOrNull?.plans.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });

  testWidgets('Check day 34', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('day-0')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-33')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(
        container
            .read(plansProvider)
            .valueOrNull
            ?.plans
            .first
            .bookmark
            .dayIndex,
        33);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });

  testWidgets('Uncheck day 10', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('day-0')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-10')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-10')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(
        container
            .read(plansProvider)
            .valueOrNull
            ?.plans
            .first
            .bookmark
            .dayIndex,
        10);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Delete plan', (tester) async {
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(container.read(plansProvider).valueOrNull?.plans.length, 1);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsOneWidget);
  });
}