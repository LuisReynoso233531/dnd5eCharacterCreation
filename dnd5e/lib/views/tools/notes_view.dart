import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/note_entry.dart';
import '../../data/repositories/notes_repository.dart';
import '../../utils/app_theme.dart';
import '../../view_models/tools/notes_view_model.dart';
import '../../view_models/tools/note_editor_view.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotesViewModel(NotesRepository())..loadNotes(),
      child: const _NotesBody(),
    );
  }
}

class _NotesBody extends StatelessWidget {
  const _NotesBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.edit_note, color: context.dndColors.warning),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, NotesViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.notes.isEmpty) {
      return _EmptyNotes(onCreateNote: () => _openEditor(context));
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadNotes,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: viewModel.notes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final note = viewModel.notes[index];

          return _NoteCard(
            note: note,
            onTap: () => _openEditor(context, note: note),
            onDelete: () => _confirmDelete(context, note),
          );
        },
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {NoteEntry? note}) async {
    final viewModel = context.read<NotesViewModel>();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: NoteEditorView(note: note),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, NoteEntry note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete note?'),
          content: Text(
            note.title.trim().isEmpty
                ? 'This untitled note will be permanently deleted.'
                : '"${note.title}" will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: context.dndColors.danger,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await context.read<NotesViewModel>().deleteNote(note.id);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The note could not be deleted.'),
          backgroundColor: context.dndColors.danger,
        ),
      );
    }
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final NoteEntry note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = note.title.trim().isEmpty
        ? 'Untitled note'
        : note.title.trim();

    final preview = note.content.trim().replaceAll(RegExp(r'\s+'), ' ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: context.dndColors.warning.withValues(
                  alpha: 0.16,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: context.dndColors.warning,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (note.isDraft) ...[
                          const SizedBox(width: 8),
                          _DraftBadge(),
                        ],
                      ],
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.dndColors.mutedText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Updated ${_formatDate(note.updatedAt)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.dndColors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();

    final sameDay =
        now.year == localDate.year &&
        now.month == localDate.month &&
        now.day == localDate.day;

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    if (sameDay) {
      return 'today at $hour:$minute';
    }

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year} at $hour:$minute';
  }
}

class _DraftBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.dndColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'DRAFT',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.dndColors.warning,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.onCreateNote});

  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: context.dndColors.warning,
            ),
            const SizedBox(height: 18),
            Text(
              'No notes yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create notes for campaign events, NPCs, quests, clues, and locations.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.dndColors.mutedText,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCreateNote,
              icon: const Icon(Icons.add),
              label: const Text('Create first note'),
            ),
          ],
        ),
      ),
    );
  }
}
