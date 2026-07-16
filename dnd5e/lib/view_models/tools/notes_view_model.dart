import 'package:flutter/foundation.dart';

import '../../data/models/note_entry.dart';
import '../../data/repositories/notes_repository.dart';

class NotesViewModel extends ChangeNotifier {
  NotesViewModel(this._repository);

  final NotesRepository _repository;

  List<NoteEntry> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<NoteEntry> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _repository.loadNotes();
      _sortNotes();
    } catch (error) {
      _error = 'The notes could not be loaded: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveNote(NoteEntry note) async {
    final previousNotes = List<NoteEntry>.from(_notes);
    final index = _notes.indexWhere((item) => item.id == note.id);

    if (index == -1) {
      _notes.add(note);
    } else {
      _notes[index] = note;
    }

    _sortNotes();
    _error = null;
    notifyListeners();

    try {
      await _repository.saveNotes(_notes);
    } catch (error) {
      _notes = previousNotes;
      _error = 'The note could not be saved: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    final previousNotes = List<NoteEntry>.from(_notes);

    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();

    try {
      await _repository.saveNotes(_notes);
    } catch (error) {
      _notes = previousNotes;
      _error = 'The note could not be deleted: $error';
      notifyListeners();
      rethrow;
    }
  }

  void _sortNotes() {
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }
}
