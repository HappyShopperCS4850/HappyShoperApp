import 'package:flutter/material.dart';

import 'profile.dart';

/// A member of a list — i.e., a user who has access to it.
/// Wraps the [Profile] plus list-specific info (membership id, whether
/// this user is the list owner).
class Member {
  /// Primary key of the list_members row.
  final String membershipId;
  final String listId;
  final String userId;
  final bool isOwner;

  /// Denormalised profile fields so UI can render without another lookup.
  final String email;
  final String displayName;
  final IconData icon;

  const Member({
    required this.membershipId,
    required this.listId,
    required this.userId,
    required this.isOwner,
    required this.email,
    required this.displayName,
    required this.icon,
  });

  /// Human-friendly label (display name, else email local part).
  String get label {
    if (displayName.trim().isNotEmpty) return displayName;
    final at = email.indexOf('@');
    if (at > 0) return email.substring(0, at);
    return email;
  }

  /// Build a member from a list_members row plus a joined profile map.
  factory Member.fromMap(
    Map<String, dynamic> row, {
    required bool isOwner,
    Profile? profile,
  }) {
    final p = profile;
    return Member(
      membershipId: row['id'] as String,
      listId: row['list_id'] as String,
      userId: row['user_id'] as String,
      isOwner: isOwner,
      email: p?.email ?? '',
      displayName: p?.displayName ?? '',
      icon: p?.icon ?? Icons.person,
    );
  }

  static IconData _iconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) return Icons.person;
    final codePoint = int.tryParse(iconString);
    if (codePoint == null) return Icons.person;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static String iconToString(IconData icon) => icon.codePoint.toString();
}
