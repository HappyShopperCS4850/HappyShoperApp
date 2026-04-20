import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/screens/manage_members_screen.dart';
import 'package:grocery/theme/app_theme.dart';

import 'helpers/test_app_state.dart';

void main() {
  setUp(() {
    AppTheme.setTheme(AppThemes.pink);
  });

  testWidgets('owner can add a member by email', (tester) async {
    final state = TestAppState(
      currentUser: makeTestUser(id: 'u1', email: 'owner@example.com'),
      lists: [
        makeList(
          id: 'list-1',
          ownerId: 'u1',
          title: 'Groceries',
          members: [
            makeMember(
              membershipId: 'm1',
              listId: 'list-1',
              userId: 'u1',
              email: 'owner@example.com',
              displayName: 'Owner',
              isOwner: true,
            ),
            makeMember(
              membershipId: 'm2',
              listId: 'list-1',
              userId: 'u2',
              email: 'friend@example.com',
              displayName: 'Friend',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ManageMembersScreen(appState: state, listId: 'list-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("You're the owner. Add members by email."),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.person_add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'neighbor@example.com',
    );
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('add')),
    );
    await tester.pumpAndSettle();

    expect(state.lastAddMemberListId, 'list-1');
    expect(state.lastAddMemberEmail, 'neighbor@example.com');
    expect(
      find.text('Added neighbor@example.com to the list.'),
      findsOneWidget,
    );
  });
}
