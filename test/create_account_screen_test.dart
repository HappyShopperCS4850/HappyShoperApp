import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/routes.dart';
import 'package:grocery/screens/create_account_screen.dart';
import 'package:grocery/screens/lists_screen.dart';
import 'package:grocery/theme/app_theme.dart';

import 'helpers/test_app_state.dart';

Future<void> pumpAuthApp(WidgetTester tester, TestAppState appState) async {
  await tester.pumpWidget(
    MaterialApp(
      initialRoute: Routes.createAccount,
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

  testWidgets('shows validation when email or password is missing', (
    tester,
  ) async {
    final state = TestAppState();
    await pumpAuthApp(tester, state);

    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();

    expect(find.text('Email and password are required'), findsOneWidget);
    expect(state.loadAllDataCalls, 0);
    expect(state.lastSignUpEmail, isNull);
    expect(state.lastSignInEmail, isNull);
  });

  testWidgets('creates an account and navigates to the lists screen', (
    tester,
  ) async {
    final state = TestAppState();
    await pumpAuthApp(tester, state);

    await tester.enterText(find.byType(TextField).at(0), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.enterText(find.byType(TextField).at(2), 'Alex');
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();

    expect(state.lastSignUpEmail, 'alex@example.com');
    expect(state.lastSignUpPassword, 'secret123');
    expect(state.lastSignUpDisplayName, 'Alex');
    expect(state.loadAllDataCalls, 1);
    expect(find.text('YOUR LISTS'), findsOneWidget);
  });

  testWidgets('switches to sign in mode and signs in successfully', (
    tester,
  ) async {
    final state = TestAppState();
    await pumpAuthApp(tester, state);

    await tester.tap(find.text('Already have an account? Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), 'sam@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'hunter2');
    await tester.tap(find.text('sign in'));
    await tester.pumpAndSettle();

    expect(state.lastSignInEmail, 'sam@example.com');
    expect(state.lastSignInPassword, 'hunter2');
    expect(state.loadAllDataCalls, 1);
    expect(find.text('YOUR LISTS'), findsOneWidget);
  });
}
