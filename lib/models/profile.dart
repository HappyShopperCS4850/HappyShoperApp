import 'package:flutter/material.dart';

/// A user profile — one row per auth user in the `profiles` table.
class Profile {
  final String id;
  final String email;
  final String displayName;
  final IconData icon;

  const Profile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.icon,
  });

  /// Prefer the display name; fall back to the email local part.
  String get label {
    if (displayName.trim().isNotEmpty) return displayName;
    final at = email.indexOf('@');
    if (at > 0) return email.substring(0, at);
    return email;
  }

  Profile copyWith({String? displayName, IconData? icon, String? email}) {
    return Profile(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
    );
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: (map['email'] ?? '') as String,
      displayName: (map['display_name'] ?? '') as String,
      icon: _iconFromString(map['icon'] as String?),
    );
  }

  static IconData _iconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.person;
    }
    final codePoint = int.tryParse(iconString);
    if (codePoint == null) return Icons.person;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static String iconToString(IconData icon) => icon.codePoint.toString();
}
