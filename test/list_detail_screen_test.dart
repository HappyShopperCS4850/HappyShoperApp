import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/screens/list_detail_screen.dart';
import 'package:grocery/theme/app_theme.dart';

import 'helpers/test_app_state.dart';

void main() {
  setUp(() {
    AppTheme.setTheme(AppThemes.pink);
  });

  testWidgets('add item creates a new list item', (tester) async {
    final state = TestAppState(
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
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ListDetailScreen(appState: state, listId: 'list-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No items yet. Tap + to add one.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Milk');
    await tester.enterText(find.byType(TextField).at(1), 'For coffee');
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('add')),
    );
    await tester.pumpAndSettle();

    expect(state.lastAddedItemListId, 'list-1');
    expect(state.lastAddedItem?.title, 'Milk');
    expect(state.lastAddedItem?.notes, 'For coffee');
    expect(find.text('Milk'), findsOneWidget);
  });

  testWidgets('long press delete removes an item', (tester) async {
    final state = TestAppState(
      lists: [
        makeList(
          id: 'list-1',
          ownerId: 'u1',
          title: 'Groceries',
          items: [makeItem(id: 'item-1', listId: 'list-1', title: 'Milk')],
          members: [
            makeMember(
              membershipId: 'm1',
              listId: 'list-1',
              userId: 'u1',
              email: 'owner@example.com',
              displayName: 'Owner',
              isOwner: true,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ListDetailScreen(appState: state, listId: 'list-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Milk'), findsOneWidget);

    await tester.longPress(find.text('Milk'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(state.lastRemovedItemListId, 'list-1');
    expect(state.lastRemovedItemId, 'item-1');
    expect(find.text('Milk'), findsNothing);
  });
}
