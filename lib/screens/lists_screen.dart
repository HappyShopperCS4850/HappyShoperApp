import 'package:flutter/material.dart';

import '../routes.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'list_detail_screen.dart';

class ListsScreen extends StatefulWidget {
  final AppState appState;
  const ListsScreen({super.key, required this.appState});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  Future<void> _openCreateListPopup() async {
    final createdList = await showDialog<_ListInfo>(
      context: context,
      builder: (_) => const CreateListPopup(),
    );
    if (!mounted || createdList == null) {
      return;
    }
    await widget.appState.addList(createdList.title, createdList.description);
  }

  Future<void> _showSearchDialog() async {
    String query = '';
    final textController = TextEditingController();
    final focusNode = FocusNode();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final matches = query.isEmpty
                  ? const <_SearchMatch>[]
                  : _searchMatches(query);
              final hasMatches = matches.isNotEmpty;

              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Search Items',
                      style: TextStyle(
                        color: dialogText(),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final fieldWidth = constraints.maxWidth;
                        return Autocomplete<_SearchMatch>(
                          textEditingController: textController,
                          focusNode: focusNode,
                          displayStringForOption: (option) => option.itemTitle,
                          optionsBuilder: (TextEditingValue value) {
                            final q = value.text.trim();
                            if (q.isEmpty) {
                              return const Iterable<_SearchMatch>.empty();
                            }
                            return _searchMatches(q);
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            fieldFocusNode,
                            onFieldSubmitted,
                          ) {
                            return TextField(
                              controller: controller,
                              focusNode: fieldFocusNode,
                              autofocus: true,
                              style: const TextStyle(color: Colors.black87),
                              decoration: const InputDecoration(
                                hintText: 'Search item name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() => query = value.trim());
                              },
                            );
                          },
                          optionsViewBuilder: (
                            context,
                            onSelected,
                            options,
                          ) {
                            final optionList = options.toList();
                            if (optionList.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: fieldWidth,
                                  margin: const EdgeInsets.only(top: 6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxHeight: 220),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: optionList.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final match = optionList[index];
                                        return InkWell(
                                          onTap: () => onSelected(match),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        match.itemTitle,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        match.isListTitle
                                                            ? 'List title match'
                                                            : 'List: ${match.listTitle}',
                                                        style: TextStyle(
                                                          color: Colors.black
                                                              .withOpacity(0.6),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      AppTheme.primary,
                                                  child: const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          onSelected: (match) {
                            Navigator.pop(dialogContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ListDetailScreen(
                                  appState: widget.appState,
                                  listId: match.listId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    if (query.isEmpty)
                      Text(
                        'Type to search your lists',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    if (query.isNotEmpty && !hasMatches)
                      Text(
                        'No matches yet',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    const SizedBox(height: 10),
                    PrimaryPillButton(
                      label: 'close',
                      onTap: () => Navigator.pop(dialogContext),
                      backgroundColor: Colors.white,
                      foregroundColor: dialogAccent(),
                      borderColor: dialogAccent(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    textController.dispose();
    focusNode.dispose();
  }

  List<_SearchMatch> _searchMatches(String query) {
    final q = query.toLowerCase();
    final matches = <_SearchMatch>[];

    for (final list in widget.appState.lists) {
      if (list.title.toLowerCase().contains(q)) {
        matches.add(
          _SearchMatch(
            listId: list.id,
            listTitle: list.title,
            itemTitle: list.title,
            isListTitle: true,
          ),
        );
      }

      for (final item in list.items) {
        if (item.title.toLowerCase().contains(q)) {
          matches.add(
            _SearchMatch(
              listId: list.id,
              listTitle: list.title,
              itemTitle: item.title,
              isListTitle: false,
            ),
          );
        }
      }
    }

    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Panel(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
        child: AnimatedBuilder(
          animation: widget.appState,
          builder: (context, _) {
            final lists = widget.appState.lists;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'YOUR LISTS',
                      style: UI.title().copyWith(fontSize: 20),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await widget.appState.signOut();
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.createAccount,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.profile),
                      icon: const Icon(Icons.person_outline,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...lists.map(
                  (list) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListRowButton(
                      title: list.title,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListDetailScreen(
                              appState: widget.appState,
                              listId: list.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CenterCircleButton(
                      onTap: _showSearchDialog,
                      icon: Icons.search,
                    ),
                    CenterCircleButton(onTap: _openCreateListPopup),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CreateListPopup extends StatefulWidget {
  const CreateListPopup({super.key});

  @override
  State<CreateListPopup> createState() => _CreateListPopupState();
}

class _CreateListPopupState extends State<CreateListPopup> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _showErrorPopup(String message) {
    final dialogTextColor = dialogAccent();

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
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
                  'Missing info',
                  style: TextStyle(
                    color: dialogTextColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: dialogTextColor),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: TextButton.styleFrom(
                      foregroundColor: dialogTextColor,
                    ),
                    child: const Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          gradient: AppGradients.panel,
          borderRadius: BorderRadius.circular(UI.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Create Grocery List',
                    style: UI.title().copyWith(fontSize: 20),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: UI.inputText,
              decoration: UI.input('title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              style: UI.inputText,
              minLines: 2,
              maxLines: 3,
              decoration: UI.input('description'),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final title = _titleController.text.trim();
                  final description = _descriptionController.text.trim();

                  if (title.isEmpty) {
                    _showErrorPopup(
                      'Please add a title before creating a list.',
                    );
                    return;
                  }

                  Navigator.pop(context, _ListInfo(title, description));
                },
                child: const Icon(Icons.add, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMatch {
  final String listId;
  final String listTitle;
  final String itemTitle;
  final bool isListTitle;

  const _SearchMatch({
    required this.listId,
    required this.listTitle,
    required this.itemTitle,
    this.isListTitle = false,
  });
}

class _ListInfo {
  final String title;
  final String description;
  const _ListInfo(this.title, this.description);
}