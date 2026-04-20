import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

/// Central app state. Streams data from Supabase in realtime and
/// exposes CRUD helpers for the UI.
class AppState extends ChangeNotifier {
  final SupabaseClient _supabase;

  AppState({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // ---------- in-memory state ------------------------------------
  final List<AppList> _lists = [];
  Profile? _profile;

  /// Cached profiles, keyed by auth user id. Used to resolve
  /// display names for items, members, etc.
  final Map<String, Profile> _profileCache = {};

  // ---------- realtime channels ----------------------------------
  RealtimeChannel? _listsChannel;
  RealtimeChannel? _membersChannel;
  RealtimeChannel? _itemsChannel;
  RealtimeChannel? _profilesChannel;

  // ---------- getters --------------------------------------------
  List<AppList> get lists => List.unmodifiable(_lists);
  Profile? get profile => _profile;
  Map<String, Profile> get profileCache => Map.unmodifiable(_profileCache);

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  String? profileNameFor(String? userId) {
    if (userId == null) return null;
    return _profileCache[userId]?.label;
  }

  AppList? getList(String id) {
    try {
      return _lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Members of a specific list (owner first, then others by name).
  List<Member> membersOf(String listId) {
    final list = getList(listId);
    if (list == null) return const [];
    final members = List<Member>.from(list.members);
    members.sort((a, b) {
      if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
      return a.label.toLowerCase().compareTo(b.label.toLowerCase());
    });
    return members;
  }

  // ===============================================================
  // LIFECYCLE
  // ===============================================================

  Future<void> loadAllData() async {
    final user = currentUser;
    if (user == null) return;

    await _fetchProfile();
    await _fetchLists();
    _startRealtime();
    notifyListeners();
  }

  void clearLocalState() {
    _stopRealtime();
    _lists.clear();
    _profile = null;
    _profileCache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopRealtime();
    super.dispose();
  }

  // ===============================================================
  // INITIAL FETCH
  // ===============================================================

  Future<void> _fetchProfile() async {
    final user = currentUser;
    if (user == null) return;

    final row = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (row != null) {
      final profile = Profile.fromMap(row);
      _profile = profile;
      _profileCache[profile.id] = profile;
    } else {
      // The DB trigger should have created this row, but create it
      // defensively just in case (e.g. when running against an older DB).
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email ?? '',
        'display_name': '',
      });
      _profile = Profile(
        id: user.id,
        email: user.email ?? '',
        displayName: '',
        icon: Icons.person,
      );
      _profileCache[user.id] = _profile!;
    }
  }

  Future<void> _fetchLists() async {
    final user = currentUser;
    if (user == null) return;

    // 1. Memberships — all list_ids the current user has access to.
    final membershipRows = await _supabase
        .from('list_members')
        .select()
        .eq('user_id', user.id);

    final listIds = (membershipRows as List)
        .map((r) => r['list_id'] as String)
        .toSet()
        .toList();

    if (listIds.isEmpty) {
      _lists.clear();
      return;
    }

    // 2. The list rows themselves.
    final listRows = await _supabase
        .from('lists')
        .select()
        .inFilter('id', listIds)
        .order('created_at');

    // 3. All memberships for those lists (so we can render members).
    final allMemberRows = await _supabase
        .from('list_members')
        .select()
        .inFilter('list_id', listIds);

    // 4. All items for those lists.
    final itemRows = await _supabase
        .from('items')
        .select()
        .inFilter('list_id', listIds)
        .order('created_at');

    // 5. Profiles for every user referenced (members + assignees).
    final userIds = <String>{};
    for (final row in (allMemberRows as List)) {
      userIds.add(row['user_id'] as String);
    }
    for (final row in (itemRows as List)) {
      final a = row['assigned_to'] as String?;
      if (a != null) userIds.add(a);
    }
    await _fetchProfilesFor(userIds);

    // 6. Build AppList objects.
    _lists
      ..clear()
      ..addAll(
        (listRows as List).map((raw) {
          final listId = raw['id'] as String;
          final ownerId = (raw['owner_id'] ?? '') as String;
          final items = itemRows
              .where((i) => i['list_id'] == listId)
              .map((i) => ListItem.fromMap(i))
              .toList();
          final members = allMemberRows
              .where((m) => m['list_id'] == listId)
              .map(
                (m) => Member.fromMap(
                  m,
                  isOwner: m['user_id'] == ownerId,
                  profile: _profileCache[m['user_id']],
                ),
              )
              .toList();
          return AppList.fromMap(raw, items: items, members: members);
        }),
      );
  }

  Future<void> _fetchProfilesFor(Set<String> userIds) async {
    final missing = userIds
        .where((id) => !_profileCache.containsKey(id))
        .toList();
    if (missing.isEmpty) return;

    final rows = await _supabase
        .from('profiles')
        .select()
        .inFilter('id', missing);

    for (final row in (rows as List)) {
      final p = Profile.fromMap(row);
      _profileCache[p.id] = p;
    }
  }

  // ===============================================================
  // REALTIME
  // ===============================================================

  void _startRealtime() {
    _stopRealtime();

    _listsChannel = _supabase
        .channel('public:lists')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lists',
          callback: (_) => _refreshFromRealtime(),
        )
        .subscribe();

    _membersChannel = _supabase
        .channel('public:list_members')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'list_members',
          callback: (_) => _refreshFromRealtime(),
        )
        .subscribe();

    _itemsChannel = _supabase
        .channel('public:items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'items',
          callback: (_) => _refreshFromRealtime(),
        )
        .subscribe();

    _profilesChannel = _supabase
        .channel('public:profiles')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            final row = payload.newRecord;
            if (row.isNotEmpty) {
              final p = Profile.fromMap(row);
              _profileCache[p.id] = p;
              if (_profile?.id == p.id) _profile = p;
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  void _stopRealtime() {
    for (final ch in [
      _listsChannel,
      _membersChannel,
      _itemsChannel,
      _profilesChannel,
    ]) {
      if (ch != null) {
        _supabase.removeChannel(ch);
      }
    }
    _listsChannel = null;
    _membersChannel = null;
    _itemsChannel = null;
    _profilesChannel = null;
  }

  /// Debounce realtime events slightly so a burst of related changes
  /// (e.g. owner added + first-member-row trigger) only triggers one
  /// refetch.
  Timer? _refreshDebounce;
  Future<void> _refreshFromRealtime() async {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 120), () async {
      try {
        await _fetchLists();
        notifyListeners();
      } catch (_) {
        // Swallow — next event will retry.
      }
    });
  }

  // ===============================================================
  // PROFILE
  // ===============================================================

  Future<void> updateProfile({String? displayName, IconData? icon}) async {
    final user = currentUser;
    if (user == null) return;

    final data = <String, dynamic>{};
    if (displayName != null) data['display_name'] = displayName;
    if (icon != null) data['icon'] = Profile.iconToString(icon);
    if (data.isEmpty) return;

    await _supabase.from('profiles').update(data).eq('id', user.id);
    await _fetchProfile();
    notifyListeners();
  }

  // ===============================================================
  // LISTS
  // ===============================================================

  Future<void> addList(String title, String description) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase.from('lists').insert({
      'owner_id': user.id,
      'title': title,
      'description': description,
    });

    await _fetchLists();
    notifyListeners();
  }

  Future<void> deleteList(String listId) async {
    await _supabase.from('lists').delete().eq('id', listId);
    await _fetchLists();
    notifyListeners();
  }

  // ===============================================================
  // LIST MEMBERS
  // ===============================================================

  /// Add a member to the list by email. Returns a human-readable
  /// error message on failure; null on success.
  Future<String?> addMemberByEmail(String listId, String rawEmail) async {
    final user = currentUser;
    if (user == null) return 'You are not signed in.';
    final email = rawEmail.trim().toLowerCase();
    if (email.isEmpty) return 'Please enter an email address.';

    final list = getList(listId);
    if (list == null) return 'List not found.';
    if (list.ownerId != user.id) {
      return 'Only the list owner can add members.';
    }

    // Look up the profile by email (case-insensitive).
    final row = await _supabase
        .from('profiles')
        .select()
        .ilike('email', email)
        .maybeSingle();

    if (row == null) {
      return 'No HappyShopper user with email "$email" was found.';
    }

    final userId = row['id'] as String;

    // Already a member?
    final already = list.members.any((m) => m.userId == userId);
    if (already) return 'That user is already on this list.';

    try {
      await _supabase.from('list_members').insert({
        'list_id': listId,
        'user_id': userId,
      });
    } on PostgrestException catch (e) {
      return 'Could not add member: ${e.message}';
    }

    await _fetchLists();
    notifyListeners();
    return null;
  }

  /// Remove a member from a list. Only the list owner may call this.
  Future<String?> removeMember(String listId, String membershipId) async {
    final user = currentUser;
    if (user == null) return 'You are not signed in.';

    final list = getList(listId);
    if (list == null) return 'List not found.';
    if (list.ownerId != user.id) {
      return 'Only the list owner can remove members.';
    }

    try {
      await _supabase.from('list_members').delete().eq('id', membershipId);
    } on PostgrestException catch (e) {
      return 'Could not remove member: ${e.message}';
    }

    await _fetchLists();
    notifyListeners();
    return null;
  }

  /// Current user leaves a shared list. Owners can't leave their own list
  /// (they delete it instead).
  Future<String?> leaveList(String listId) async {
    final user = currentUser;
    if (user == null) return 'You are not signed in.';

    final list = getList(listId);
    if (list == null) return 'List not found.';
    if (list.ownerId == user.id) {
      return 'Owners cannot leave their own list — delete it instead.';
    }

    try {
      await _supabase
          .from('list_members')
          .delete()
          .eq('list_id', listId)
          .eq('user_id', user.id);
    } on PostgrestException catch (e) {
      return 'Could not leave list: ${e.message}';
    }

    await _fetchLists();
    notifyListeners();
    return null;
  }

  // ===============================================================
  // ITEMS
  // ===============================================================

  /// Create a local ListItem (not persisted yet) with a fresh id
  /// placeholder. Useful for dialogs that build up an item before
  /// saving.
  ListItem createItem({
    required String title,
    required IconData icon,
    required String qty,
    required String notes,
    String? assignedTo,
  }) {
    return ListItem(
      id: '',
      listId: '',
      title: title,
      icon: icon,
      qty: qty,
      notes: notes,
      completed: false,
      assignedTo: assignedTo,
    );
  }

  Future<void> addItem(String listId, ListItem item) async {
    await _supabase.from('items').insert({
      'list_id': listId,
      'title': item.title,
      'qty': item.qty,
      'notes': item.notes,
      'completed': item.completed,
      'icon': ListItem.iconToString(item.icon),
      'assigned_to': item.assignedTo,
    });
    await _fetchLists();
    notifyListeners();
  }

  Future<void> updateItem(
    String listId,
    String itemId, {
    bool? completed,
    String? assignedTo,
  }) async {
    final data = <String, dynamic>{};
    if (completed != null) data['completed'] = completed;
    if (assignedTo != null) data['assigned_to'] = assignedTo;
    if (data.isEmpty) return;

    await _supabase.from('items').update(data).eq('id', itemId);
    await _fetchLists();
    notifyListeners();
  }

  Future<void> removeItem(String listId, String itemId) async {
    await _supabase.from('items').delete().eq('id', itemId);
    await _fetchLists();
    notifyListeners();
  }

  // ===============================================================
  // AUTH
  // ===============================================================

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName == null || displayName.isEmpty
          ? null
          : {'display_name': displayName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    clearLocalState();
  }
}
