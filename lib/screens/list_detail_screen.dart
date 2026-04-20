import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'manage_members_screen.dart';

class ListDetailScreen extends StatefulWidget {
  final AppState appState;
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.appState,
    required this.listId,
  });

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  String? _memberLabelFor(String? userId, List<Member> members) {
    if (userId == null) return null;
    for (final member in members) {
      if (member.userId == userId) return member.label;
    }
    // Fall back to profile cache (user may have left the list).
    return widget.appState.profileNameFor(userId);
  }

  Future<void> _showItemActions({
    required ListItem item,
    Offset? position,
  }) async {
    String? action;

    if (position != null) {
      final overlay =
          Overlay.of(context).context.findRenderObject() as RenderBox;
      final menuPosition = RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Offset.zero & overlay.size,
      );
      action = await showMenu<String>(
        context: context,
        position: menuPosition,
        color: Colors.white,
        items: [
          PopupMenuItem(
            value: 'toggle',
            child: Text(
              item.completed ? 'Mark as incomplete' : 'Mark as complete',
            ),
          ),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      );
    } else {
      action = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  title: Text(
                    item.completed ? 'Mark as incomplete' : 'Mark as complete',
                  ),
                  onTap: () => Navigator.pop(context, 'toggle'),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text('Delete'),
                  onTap: () => Navigator.pop(context, 'delete'),
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      );
    }

    if (!mounted || action == null) return;

    if (action == 'delete') {
      await widget.appState.removeItem(widget.listId, item.id);
    } else if (action == 'toggle') {
      await widget.appState.updateItem(
        widget.listId,
        item.id,
        completed: !item.completed,
      );
    }
  }

  Future<void> _showAddItemDialog(List<Member> members) async {
    String name = '';
    int qty = 1;
    String notes = '';
    String? selectedUserId;

    final accent = dialogAccent();
    final textColor = dialogText();

    final iconOptions = <IconData>[
      Icons.shopping_basket,
      Icons.local_grocery_store,
      Icons.fastfood,
      Icons.emoji_food_beverage,
      Icons.bakery_dining,
      Icons.local_drink,
      Icons.cleaning_services,
      Icons.medication,
    ];

    IconData selectedIcon = iconOptions.first;

    final createdItem = await showDialog<ListItem>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Item',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        autofocus: true,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          hintText: 'Item name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => name = value.trim());
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Quantity',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _QtyButton(
                            icon: Icons.remove,
                            color: accent,
                            onTap: () {
                              setState(() {
                                if (qty > 1) qty -= 1;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            qty.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _QtyButton(
                            icon: Icons.add,
                            color: accent,
                            onTap: () {
                              setState(() => qty += 1);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Icon',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: iconOptions.map((icon) {
                          final selected = icon == selectedIcon;
                          final optionBg =
                              selected ? accent : AppTheme.primary;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedIcon = icon),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: optionBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? Colors.white : accent,
                                  width: selected ? 2 : 1.2,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Who is this for?',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (members.length <= 1)
                        Text(
                          'No other members yet. Add collaborators from the list\'s people icon.',
                          style: TextStyle(
                            color: textColor.withOpacity(0.7),
                          ),
                        )
                      else
                        DropdownButtonFormField<String?>(
                          value: selectedUserId,
                          dropdownColor: Colors.white,
                          iconEnabledColor: accent,
                          isExpanded: true,
                          hint: Text(
                            'Unassigned',
                            style: TextStyle(color: textColor),
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(
                                'Unassigned',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                            ...members.map(
                              (member) => DropdownMenuItem<String?>(
                                value: member.userId,
                                child: Row(
                                  children: [
                                    Icon(
                                      member.icon,
                                      size: 18,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      member.label,
                                      style: TextStyle(color: textColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => selectedUserId = value);
                          },
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: textColor),
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => notes = value.trim());
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryPillButton(
                              label: 'cancel',
                              onTap: () => Navigator.pop(dialogContext),
                              backgroundColor: Colors.white,
                              foregroundColor: accent,
                              borderColor: accent,
                              icon: Icons.delete_outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryPillButton(
                              label: 'add',
                              onTap: name.isEmpty
                                  ? null
                                  : () => Navigator.pop(
                                        dialogContext,
                                        widget.appState.createItem(
                                          title: name,
                                          icon: selectedIcon,
                                          qty: qty.toString(),
                                          notes: notes,
                                          assignedTo: selectedUserId,
                                        ),
                                      ),
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              borderColor: accent,
                              icon: Icons.add,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (!mounted || createdItem == null) return;
    await widget.appState.addItem(widget.listId, createdItem);
  }

  Future<void> _confirmDeleteOrLeave({
    required bool isOwner,
    required String listTitle,
  }) async {
    final accent = dialogAccent();
    final textColor = dialogText();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isOwner ? 'Delete "$listTitle"?' : 'Leave "$listTitle"?',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isOwner
                    ? 'This will permanently delete the list and all of its items for every member.'
                    : 'You will lose access to this list. The owner can re-add you later.',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: PrimaryPillButton(
                      label: 'cancel',
                      onTap: () => Navigator.pop(dialogContext, false),
                      backgroundColor: Colors.white,
                      foregroundColor: accent,
                      borderColor: accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryPillButton(
                      label: isOwner ? 'delete' : 'leave',
                      onTap: () => Navigator.pop(dialogContext, true),
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      borderColor: accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    String? error;
    try {
      if (isOwner) {
        await widget.appState.deleteList(widget.listId);
      } else {
        error = await widget.appState.leaveList(widget.listId);
      }
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final list = widget.appState.getList(widget.listId);
            if (list == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('', style: UI.title())),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'This list is no longer available.',
                    style: UI.subtitle(),
                  ),
                ],
              );
            }

            final items = list.items;
            final members = widget.appState.membersOf(widget.listId);
            final me = widget.appState.currentUser;
            final isOwner = list.isOwnedBy(me?.id);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        list.title,
                        style: UI.title().copyWith(height: 1.05),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Members',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageMembersScreen(
                            appState: widget.appState,
                            listId: widget.listId,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.group, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: isOwner ? 'Delete list' : 'Leave list',
                      onPressed: () => _confirmDeleteOrLeave(
                        isOwner: isOwner,
                        listTitle: list.title,
                      ),
                      icon: Icon(
                        isOwner ? Icons.delete_outline : Icons.logout,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                if (list.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    list.description,
                    style: UI.subtitle().copyWith(
                      color: AppTheme.secondary.withOpacity(0.9),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  members.length == 1
                      ? 'Just you'
                      : '${members.length} members',
                  style: UI.subtitle().copyWith(
                    color: AppTheme.secondary.withOpacity(0.75),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No items yet. Tap + to add one.',
                            style: UI.subtitle(),
                          ),
                        )
                      : GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                          itemBuilder: (context, i) {
                            final it = items[i];
                            final isComplete = it.completed;
                            final assignedName =
                                _memberLabelFor(it.assignedTo, members);

                            return GestureDetector(
                              onLongPress: () => _showItemActions(item: it),
                              onSecondaryTapDown: (details) {
                                _showItemActions(
                                  item: it,
                                  position: details.globalPosition,
                                );
                              },
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => widget.appState.updateItem(
                                  widget.listId,
                                  it.id,
                                  completed: !it.completed,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      isComplete ? 0.08 : 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        it.icon,
                                        color: Colors.white.withOpacity(
                                          isComplete ? 0.55 : 1.0,
                                        ),
                                        size: 44,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        it.title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppTheme.secondary.withOpacity(
                                            isComplete ? 0.6 : 1.0,
                                          ),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          decoration: isComplete
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      if (it.qty.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          it.qty,
                                          style: TextStyle(
                                            color:
                                                AppTheme.secondary.withOpacity(
                                              isComplete ? 0.6 : 0.85,
                                            ),
                                            fontWeight: FontWeight.w800,
                                            decoration: isComplete
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                      if (assignedName != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'For $assignedName',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                AppTheme.secondary.withOpacity(
                                              isComplete ? 0.6 : 0.8,
                                            ),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 10),
                CenterCircleButton(
                  onTap: () => _showAddItemDialog(members),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  icon: Icons.add,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          side: BorderSide(color: color),
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onTap,
        child: Icon(icon, size: 16),
      ),
    );
  }
}
