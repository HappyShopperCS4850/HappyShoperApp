import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/models/models.dart';

import 'helpers/test_app_state.dart';

void main() {
  test('Profile.label prefers display name and falls back to email prefix', () {
    const named = Profile(
      id: 'u1',
      email: 'alex@example.com',
      displayName: 'Alex Rivera',
      icon: Icons.person,
    );
    const unnamed = Profile(
      id: 'u2',
      email: 'sam@example.com',
      displayName: '',
      icon: Icons.person,
    );

    expect(named.label, 'Alex Rivera');
    expect(unnamed.label, 'sam');
  });

  test('Profile.fromMap parses the stored icon code point', () {
    final map = <String, dynamic>{
      'id': 'u1',
      'email': 'alex@example.com',
      'display_name': 'Alex',
      'icon': Profile.iconToString(Icons.face),
    };

    final profile = Profile.fromMap(map);

    expect(profile.id, 'u1');
    expect(profile.email, 'alex@example.com');
    expect(profile.displayName, 'Alex');
    expect(profile.icon.codePoint, Icons.face.codePoint);
  });

  test('Member.fromMap uses the joined profile details', () {
    final profile = makeProfile(
      id: 'u2',
      email: 'friend@example.com',
      displayName: 'Friend',
      icon: Icons.star,
    );

    final member = Member.fromMap(
      {'id': 'm1', 'list_id': 'list-1', 'user_id': 'u2'},
      isOwner: true,
      profile: profile,
    );

    expect(member.membershipId, 'm1');
    expect(member.listId, 'list-1');
    expect(member.userId, 'u2');
    expect(member.isOwner, isTrue);
    expect(member.label, 'Friend');
    expect(member.email, 'friend@example.com');
    expect(member.icon.codePoint, Icons.star.codePoint);
  });

  test('ListItem.fromMap parses fields and defaults missing values', () {
    final item = ListItem.fromMap({
      'id': 'i1',
      'list_id': 'list-1',
      'title': 'Milk',
      'qty': '2',
      'notes': 'Whole milk',
      'completed': true,
      'assigned_to': 'u3',
      'icon': ListItem.iconToString(Icons.local_drink),
    });

    expect(item.id, 'i1');
    expect(item.listId, 'list-1');
    expect(item.title, 'Milk');
    expect(item.qty, '2');
    expect(item.notes, 'Whole milk');
    expect(item.completed, isTrue);
    expect(item.assignedTo, 'u3');
    expect(item.icon.codePoint, Icons.local_drink.codePoint);
  });

  test('AppList.isOwnedBy checks the owner id', () {
    const list = AppList(
      id: 'list-1',
      ownerId: 'owner-1',
      title: 'Groceries',
      description: 'Weekly shop',
      items: [],
      members: [],
    );

    expect(list.isOwnedBy('owner-1'), isTrue);
    expect(list.isOwnedBy('someone-else'), isFalse);
    expect(list.isOwnedBy(null), isFalse);
  });

  test(
    'AppState.membersOf sorts owner first and then labels alphabetically',
    () {
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
                displayName: 'Zoe',
                isOwner: true,
              ),
              makeMember(
                membershipId: 'm2',
                listId: 'list-1',
                userId: 'u2',
                email: 'amy@example.com',
                displayName: 'Amy',
              ),
              makeMember(
                membershipId: 'm3',
                listId: 'list-1',
                userId: 'u3',
                email: 'ben@example.com',
                displayName: 'ben',
              ),
            ],
          ),
        ],
      );

      final members = state.membersOf('list-1');

      expect(members.map((member) => member.label), ['Zoe', 'Amy', 'ben']);
    },
  );
}
