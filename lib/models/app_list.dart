import 'list_item.dart';
import 'member.dart';

class AppList {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final List<ListItem> items;
  final List<Member> members;

  const AppList({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.items,
    required this.members,
  });

  /// True if the currently-signed-in user is the owner of this list.
  bool isOwnedBy(String? userId) => userId != null && userId == ownerId;

  AppList copyWith({
    String? title,
    String? description,
    List<ListItem>? items,
    List<Member>? members,
  }) {
    return AppList(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      members: members ?? this.members,
    );
  }

  factory AppList.fromMap(
    Map<String, dynamic> map, {
    required List<ListItem> items,
    required List<Member> members,
  }) {
    return AppList(
      id: map['id'] as String,
      ownerId: (map['owner_id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      items: items,
      members: members,
    );
  }
}
