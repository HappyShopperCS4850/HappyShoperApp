import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// Shows the members of a single [listId]. The list owner can add
/// members by email and remove anyone; non-owners can only leave.
class ManageMembersScreen extends StatelessWidget {
  final AppState appState;
  final String listId;

  const ManageMembersScreen({
    super.key,
    required this.appState,
    required this.listId,
  });

  Future<void> _addByEmail(BuildContext context) async {
    final controller = TextEditingController();
    final accent = dialogAccent();
    final textColor = dialogText();

    final email = await showDialog<String>(
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
                'Add member by email',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'They must already have a HappyShopper account.',
                style: TextStyle(color: textColor.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  hintText: 'person@example.com',
                  border: OutlineInputBorder(),
                ),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryPillButton(
                      label: 'add',
                      onTap: () => Navigator.pop(
                        dialogContext,
                        controller.text.trim(),
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
      ),
    );

    if (email == null || email.isEmpty) return;

    final error = await appState.addMemberByEmail(listId, email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Added $email to the list.')),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    Member member, {
    required bool isSelfLeave,
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
                isSelfLeave ? 'Leave list?' : 'Remove member?',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isSelfLeave
                    ? "You will lose access to this list. You can be re-added later."
                    : 'Remove ${member.label} from this list?',
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
                      label: isSelfLeave ? 'leave' : 'remove',
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

    final error = isSelfLeave
        ? await appState.leaveList(listId)
        : await appState.removeMember(listId, member.membershipId);

    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else if (isSelfLeave) {
      Navigator.pop(context); // close members screen
      Navigator.pop(context); // pop list detail (they no longer have access)
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final list = appState.getList(listId);
            if (list == null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('MEMBERS',
                          style: UI.title().copyWith(fontSize: 20)),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'This list is no longer available.',
                    style: UI.subtitle(),
                  ),
                ],
              );
            }

            final me = appState.currentUser;
            final isOwner = list.isOwnedBy(me?.id);
            final members = appState.membersOf(listId);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'MEMBERS OF ${list.title.toUpperCase()}',
                        style: UI.title().copyWith(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        onPressed: () => _addByEmail(context),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isOwner
                      ? "You're the owner. Add members by email."
                      : 'Owner: ${list.members.firstWhere((m) => m.isOwner, orElse: () => members.first).label}',
                  style: UI.subtitle()
                      .copyWith(color: AppTheme.secondary.withOpacity(0.8)),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final m = members[i];
                      final isSelf = m.userId == me?.id;
                      final canRemove = !m.isOwner && (isOwner || isSelf);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primary,
                              child: Icon(m.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.label + (isSelf ? ' (you)' : ''),
                                    style: TextStyle(
                                      color: AppTheme.secondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (m.email.isNotEmpty)
                                    Text(
                                      m.email,
                                      style: TextStyle(
                                        color: AppTheme.secondary.withOpacity(0.75),
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (m.isOwner)
                                    Text(
                                      'Owner',
                                      style: TextStyle(
                                        color: AppTheme.secondary.withOpacity(0.8),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (canRemove)
                              IconButton(
                                icon: Icon(
                                  isSelf ? Icons.logout : Icons.delete_outline,
                                  color: Colors.white,
                                ),
                                tooltip: isSelf ? 'Leave list' : 'Remove',
                                onPressed: () => _confirmRemove(
                                  context,
                                  m,
                                  isSelfLeave: isSelf,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
