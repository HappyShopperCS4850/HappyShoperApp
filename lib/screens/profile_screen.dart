import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final AppState appState;
  const ProfileScreen({super.key, required this.appState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _themePreference = 'Default';

  @override
  void initState() {
    super.initState();
    _themePreference = AppTheme.notifier.value.label;
  }

  Future<void> _showEditNameDialog(Profile profile) async {
    final controller = TextEditingController(text: profile.displayName);
    final accent = dialogAccent();
    final textColor = dialogText();

    final newName = await showDialog<String>(
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
                'Edit your name',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: textColor),
                decoration: const InputDecoration(
                  hintText: 'Your name',
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
                      label: 'save',
                      onTap: () =>
                          Navigator.pop(dialogContext, controller.text.trim()),
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      borderColor: accent,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (newName == null) return;
    await widget.appState.updateProfile(displayName: newName);
  }

  Future<void> _showProfileIconDialog(Profile profile) async {
    final iconOptions = <IconData>[
      Icons.person,
      Icons.face,
      Icons.pets,
      Icons.sports_esports,
      Icons.shopping_bag,
      Icons.local_florist,
      Icons.music_note,
      Icons.star,
    ];
    IconData selectedIcon = profile.icon;
    final accent = dialogAccent();
    final textColor = dialogText();

    final picked = await showDialog<IconData>(
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Update Profile Icon',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: iconOptions.map((icon) {
                        final selected = icon == selectedIcon;
                        final optionBg =
                            selected ? accent : AppTheme.primary;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = icon),
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
                            child: Icon(icon, size: 20, color: Colors.white),
                          ),
                        );
                      }).toList(),
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
                            label: 'save',
                            onTap: () =>
                                Navigator.pop(dialogContext, selectedIcon),
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            borderColor: accent,
                            icon: Icons.check,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (picked == null) return;
    await widget.appState.updateProfile(icon: picked);
  }

  Future<void> _showThemeDialog() async {
    final themes = AppThemes.all;
    String selected = _themePreference;
    final textColor = dialogText();
    final accent = dialogAccent();

    final picked = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Theme Preferences',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                    child: Column(
                      children: themes.map((theme) {
                        final isSelected = theme.label == selected;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => setState(() {
                              selected = theme.label;
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? accent : Colors.black12,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: theme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      theme.label,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
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
                            label: 'save',
                            onTap: () =>
                                Navigator.pop(dialogContext, selected),
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            borderColor: accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (!mounted || picked == null) return;
    final pickedTheme = AppThemes.byLabel(picked);
    setState(() {
      _themePreference = picked;
    });
    AppTheme.setTheme(pickedTheme);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final profile = widget.appState.profile ??
                Profile(
                  id: '',
                  email: widget.appState.currentUser?.email ?? '',
                  displayName: '',
                  icon: Icons.person,
                );

            final displayName = profile.displayName.trim().isEmpty
                ? 'Add your name'
                : profile.displayName;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text('PROFILE',
                        style: UI.title().copyWith(fontSize: 20)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: GestureDetector(
                    onTap: () => _showProfileIconDialog(profile),
                    onLongPress: () => _showProfileIconDialog(profile),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.22),
                      child: Icon(profile.icon,
                          color: Colors.white, size: 30),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: UI.title().copyWith(fontSize: 18),
                ),
                if (profile.email.isNotEmpty)
                  Text(
                    profile.email,
                    textAlign: TextAlign.center,
                    style: UI.subtitle()
                        .copyWith(color: AppTheme.secondary.withOpacity(0.75)),
                  ),
                const SizedBox(height: 14),
                _ProfileInfoSection(
                  children: [
                    _ProfileInfoRow(
                      icon: Icons.person_outline,
                      title: 'Your Name',
                      subtitle: profile.displayName.trim().isEmpty
                          ? 'Tap to add your name'
                          : profile.displayName,
                      onTap: () => _showEditNameDialog(profile),
                    ),
                    _ProfileInfoRow(
                      icon: Icons.face,
                      title: 'Profile Icon',
                      subtitle: 'Tap to change',
                      onTap: () => _showProfileIconDialog(profile),
                    ),
                    _ProfileInfoRow(
                      icon: Icons.tune,
                      title: 'App Preferences',
                      subtitle: _themePreference,
                      onTap: _showThemeDialog,
                    ),
                  ],
                ),
                const Spacer(),
                PrimaryPillButton(
                  label: 'back',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  final List<Widget> children;
  const _ProfileInfoSection({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 1) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Divider(
            height: 1,
            color: AppTheme.secondary.withOpacity(0.24),
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: rows),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.secondary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}
