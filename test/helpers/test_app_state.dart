import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:grocery/models/models.dart';
import 'package:grocery/state/app_state.dart';

SupabaseClient makeTestSupabaseClient() {
  return SupabaseClient(
    'http://127.0.0.1:54321',
    'test-anon-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
}

User makeTestUser({required String id, String email = 'test@example.com'}) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: null,
    aud: 'authenticated',
    email: email,
    phone: null,
    createdAt: '2024-01-01T00:00:00Z',
  );
}

Profile makeProfile({
  required String id,
  required String email,
  String displayName = '',
  IconData icon = Icons.person,
}) {
  return Profile(id: id, email: email, displayName: displayName, icon: icon);
}

Member makeMember({
  required String membershipId,
  required String listId,
  required String userId,
  required String email,
  String displayName = '',
  bool isOwner = false,
  IconData icon = Icons.person,
}) {
  return Member(
    membershipId: membershipId,
    listId: listId,
    userId: userId,
    isOwner: isOwner,
    email: email,
    displayName: displayName,
    icon: icon,
  );
}

ListItem makeItem({
  required String id,
  required String listId,
  required String title,
  String qty = '1',
  String notes = '',
  bool completed = false,
  String? assignedTo,
  IconData icon = Icons.shopping_basket,
}) {
  return ListItem(
    id: id,
    listId: listId,
    title: title,
    icon: icon,
    qty: qty,
    notes: notes,
    completed: completed,
    assignedTo: assignedTo,
  );
}

AppList makeList({
  required String id,
  required String ownerId,
  required String title,
  String description = '',
  List<ListItem> items = const [],
  List<Member> members = const [],
}) {
  return AppList(
    id: id,
    ownerId: ownerId,
    title: title,
    description: description,
    items: items,
    members: members,
  );
}

class TestAppState extends AppState {
  TestAppState({
    List<AppList> lists = const [],
    Profile? profile,
    User? currentUser,
    Map<String, Profile> profileCache = const {},
    AuthResponse? signUpResponse,
    AuthResponse? signInResponse,
    String? addMemberError,
  }) : _lists = List<AppList>.from(lists),
       _profile = profile,
       _currentUser = currentUser,
       _profileCache = Map<String, Profile>.from(profileCache),
       _signUpResponse = signUpResponse,
       _signInResponse = signInResponse,
       _addMemberError = addMemberError,
       super(supabase: makeTestSupabaseClient());

  final List<AppList> _lists;
  Profile? _profile;
  User? _currentUser;
  final Map<String, Profile> _profileCache;

  AuthResponse? _signUpResponse;
  AuthResponse? _signInResponse;
  String? _addMemberError;

  int loadAllDataCalls = 0;
  int signOutCalls = 0;

  String? lastSignUpEmail;
  String? lastSignUpPassword;
  String? lastSignUpDisplayName;

  String? lastSignInEmail;
  String? lastSignInPassword;

  String? lastAddedListTitle;
  String? lastAddedListDescription;

  String? lastAddedItemListId;
  ListItem? lastAddedItem;

  String? lastRemovedItemListId;
  String? lastRemovedItemId;

  String? lastUpdatedItemListId;
  String? lastUpdatedItemId;
  bool? lastUpdatedItemCompleted;
  String? lastUpdatedItemAssignedTo;

  String? lastDeletedListId;
  String? lastRemovedMemberListId;
  String? lastRemovedMemberId;
  String? lastLeftListId;

  String? lastAddMemberListId;
  String? lastAddMemberEmail;

  String? lastUpdatedProfileDisplayName;
  IconData? lastUpdatedProfileIcon;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  void setLists(List<AppList> lists) {
    _lists
      ..clear()
      ..addAll(lists);
    notifyListeners();
  }

  @override
  List<AppList> get lists => List.unmodifiable(_lists);

  @override
  Profile? get profile => _profile;

  @override
  Map<String, Profile> get profileCache => Map.unmodifiable(_profileCache);

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isLoggedIn => _currentUser != null;

  @override
  String? profileNameFor(String? userId) {
    if (userId == null) return null;
    return _profileCache[userId]?.label;
  }

  @override
  AppList? getList(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> loadAllData() async {
    loadAllDataCalls += 1;
  }

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    lastSignUpEmail = email;
    lastSignUpPassword = password;
    lastSignUpDisplayName = displayName;
    return _signUpResponse ??
        AuthResponse(
          user: makeTestUser(id: 'signed-up', email: email),
        );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    lastSignInEmail = email;
    lastSignInPassword = password;
    return _signInResponse ??
        AuthResponse(
          user: makeTestUser(id: 'signed-in', email: email),
        );
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
    _currentUser = null;
    notifyListeners();
  }

  @override
  Future<void> addList(String title, String description) async {
    lastAddedListTitle = title;
    lastAddedListDescription = description;

    _lists.add(
      AppList(
        id: 'list-${_lists.length + 1}',
        ownerId: currentUser?.id ?? 'owner',
        title: title,
        description: description,
        items: const [],
        members: const [],
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> deleteList(String listId) async {
    lastDeletedListId = listId;
    _lists.removeWhere((list) => list.id == listId);
    notifyListeners();
  }

  @override
  Future<void> addItem(String listId, ListItem item) async {
    lastAddedItemListId = listId;
    lastAddedItem = item;

    final index = _lists.indexWhere((list) => list.id == listId);
    if (index == -1) return;

    final storedItem = ListItem(
      id: 'item-${DateTime.now().microsecondsSinceEpoch}',
      listId: listId,
      title: item.title,
      icon: item.icon,
      qty: item.qty,
      notes: item.notes,
      completed: item.completed,
      assignedTo: item.assignedTo,
    );

    final list = _lists[index];
    _lists[index] = list.copyWith(items: [...list.items, storedItem]);
    notifyListeners();
  }

  @override
  Future<void> updateItem(
    String listId,
    String itemId, {
    bool? completed,
    String? assignedTo,
  }) async {
    lastUpdatedItemListId = listId;
    lastUpdatedItemId = itemId;
    lastUpdatedItemCompleted = completed;
    lastUpdatedItemAssignedTo = assignedTo;

    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex == -1) return;

    final list = _lists[listIndex];
    final itemIndex = list.items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final current = list.items[itemIndex];
    final updatedItems = List<ListItem>.from(list.items);
    updatedItems[itemIndex] = current.copyWith(
      completed: completed,
      assignedTo: assignedTo,
    );
    _lists[listIndex] = list.copyWith(items: updatedItems);
    notifyListeners();
  }

  @override
  Future<void> removeItem(String listId, String itemId) async {
    lastRemovedItemListId = listId;
    lastRemovedItemId = itemId;

    final index = _lists.indexWhere((list) => list.id == listId);
    if (index == -1) return;

    final list = _lists[index];
    _lists[index] = list.copyWith(
      items: list.items.where((item) => item.id != itemId).toList(),
    );
    notifyListeners();
  }

  @override
  Future<String?> addMemberByEmail(String listId, String rawEmail) async {
    lastAddMemberListId = listId;
    lastAddMemberEmail = rawEmail;
    return _addMemberError;
  }

  @override
  Future<String?> removeMember(String listId, String membershipId) async {
    lastRemovedMemberListId = listId;
    lastRemovedMemberId = membershipId;
    return null;
  }

  @override
  Future<String?> leaveList(String listId) async {
    lastLeftListId = listId;
    return null;
  }

  @override
  Future<void> updateProfile({String? displayName, IconData? icon}) async {
    lastUpdatedProfileDisplayName = displayName;
    lastUpdatedProfileIcon = icon;
    if (_profile != null) {
      _profile = _profile!.copyWith(displayName: displayName, icon: icon);
    }
    notifyListeners();
  }
}
