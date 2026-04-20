import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/routes.dart';
import 'package:grocery/screens/create_account_screen.dart';
import 'package:grocery/screens/lists_screen.dart';
import 'package:grocery/theme/app_theme.dart';

import 'helpers/test_app_state.dart';

Future<void> pumpListsApp(WidgetTester tester, TestAppState appState) async {
  await tester.pumpWidget(
    MaterialApp(
      initialRoute: Routes.lists,
      routes: {
        Routes.createAccount: (_) => CreateAccountScreen(appState: appState),
        Routes.lists: (_) => ListsScreen(appState: appState),
        Routes.profile: (_) => const Scaffold(body: SizedBox()),
        Routes.listDetail: (_) => const Scaffold(body: SizedBox()),
      },
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AppTheme.setTheme(AppThemes.pink);
  });

  testWidgets('sign out returns to the create account screen', (tester) async {
    final state = TestAppState(
      lists: [makeList(id: 'list-1', ownerId: 'u1', title: 'Weekly Groceries')],
      currentUser: makeTestUser(id: 'u1', email: 'owner@example.com'),
    );
    await pumpListsApp(tester, state);

    expect(find.text('YOUR LISTS'), findsOneWidget);
    expect(find.text('Weekly Groceries'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(state.signOutCalls, 1);
    expect(find.text('Create an Account'), findsOneWidget);
  });

  testWidgets('create list shows validation when the title is empty', (
    tester,
  ) async {
    final state = TestAppState();
    await pumpListsApp(tester, state);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Missing info'), findsOneWidget);
    expect(
      find.text('Please add a title before creating a list.'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(state.lastAddedListTitle, isNull);
  });

  testWidgets('create list submits the title and description', (tester) async {
    final state = TestAppState();
    await pumpListsApp(tester, state);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Weekend Shop');
    await tester.enterText(find.byType(TextField).at(1), 'Produce and pantry');
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.byIcon(Icons.add),
      ),
    );
    await tester.pumpAndSettle();

    expect(state.lastAddedListTitle, 'Weekend Shop');
    expect(state.lastAddedListDescription, 'Produce and pantry');
    expect(find.text('Weekend Shop'), findsOneWidget);
    expect(find.text('Create Grocery List'), findsNothing);
  });
}
