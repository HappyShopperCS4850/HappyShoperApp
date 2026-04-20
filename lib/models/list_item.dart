import 'package:flutter/material.dart';

class ListItem {
  final String id;
  final String listId;
  final String title;
  final IconData icon;
  final String qty;
  final String notes;
  final bool completed;

  /// The auth user id that this item is assigned to (nullable).
  /// Replaces the old `memberId` column which pointed at the
  /// per-user `members` table.
  final String? assignedTo;

  const ListItem({
    required this.id,
    required this.listId,
    required this.title,
    required this.icon,
    required this.qty,
    required this.notes,
    required this.completed,
    this.assignedTo,
  });

  ListItem copyWith({
    bool? completed,
    String? assignedTo,
  }) {
    return ListItem(
      id: id,
      listId: listId,
      title: title,
      icon: icon,
      qty: qty,
      notes: notes,
      completed: completed ?? this.completed,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }

  factory ListItem.fromMap(Map<String, dynamic> map) {
    return ListItem(
      id: map['id'] as String,
      listId: (map['list_id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      icon: _iconFromString(map['icon'] as String?),
      qty: (map['qty'] ?? '') as String,
      notes: (map['notes'] ?? '') as String,
      completed: (map['completed'] ?? false) as bool,
      assignedTo: map['assigned_to'] as String?,
    );
  }

  static IconData _iconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.shopping_basket;
    }
    final codePoint = int.tryParse(iconString);
    if (codePoint == null) return Icons.shopping_basket;
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  static String iconToString(IconData icon) => icon.codePoint.toString();
}
