import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/note_entry.dart';
import '../../utils/app_theme.dart';
import '../../view_models/tools/notes_view_model.dart';

class NoteEditorView extends StatefulWidget {
  const NoteEditorView({
    super.key,
    this.note,
  });

  final NoteEntry? note;

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView>
    with WidgetsBindingObserver {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final String _noteId;
  late final DateTime _createdAt;

  late NotesViewModel _notesViewModel;

  Timer? _autosaveTimer;
  Future<void> _saveChain = Future<void>.value();

  NoteEntry? _storedNote;
  DateTime? _lastSavedAt;

  bool _isSaving = false;
  bool _viewModelInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _storedNote = widget.note;
    _noteId =
        widget.note?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    _createdAt = widget.note?.createdAt ?? DateTime.now();

    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_viewModelInitialized) {
      _notesViewModel = context.read<NotesViewModel>();
      _viewModelInitialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveNote());
    }
  }

  void _onTextChanged() {
    _autosaveTimer?.cancel();

    _autosaveTimer = Timer(
      const Duration(milliseconds: 600),
      _saveNote,
    );

    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasContent {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;
  }

  Future<void> _saveNote({
    bool finishDraft = false,
  }) async {
    _autosaveTimer?.cancel();

    if (!_hasContent && widget.note == null) {
      return;
    }

    final now = DateTime.now();

    final note = NoteEntry(
      id: _noteId,
      title: _titleController.text.trim(),
      content: _contentController.text,
      createdAt: _createdAt,
      updatedAt: now,
      isDraft: finishDraft
          ? false
          : (_storedNote?.isDraft ?? true),
    );

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    _saveChain = _saveChain.then(
      (_) => _notesViewModel.saveNote(note),
    );

    try {
      await _saveChain;

      _storedNote = note;
      _lastSavedAt = now;

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The note could not be saved.'),
          backgroundColor: context.dndColors.danger,
        ),
      );
    }
  }

  Future<bool> _handleBack() async {
    await _saveNote();
    return true;
  }

  Future<void> _finishNote() async {
    if (!_hasContent) {
      Navigator.pop(context);
      return;
    }

    await _saveNote(finishDraft: true);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String get _statusText {
    if (_isSaving) {
      return 'Saving...';
    }

    if (_lastSavedAt != null) {
      return 'Saved automatically';
    }

    if (_storedNote?.isDraft ?? true) {
      return 'Draft';
    }

    return 'Saved';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _autosaveTimer?.cancel();
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);

    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note'),
              Text(
                _statusText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'Finish note',
                onPressed: _finishNote,
                icon: const Icon(Icons.check),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _titleController,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Note title',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: TextField(
                    controller: _contentController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText:
                          'Write campaign events, NPC details, quests, clues...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}