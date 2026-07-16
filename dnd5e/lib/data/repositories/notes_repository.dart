import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_entry.dart';

class NotesRepository {
  static const String _storageKey = 'campaign_notes_v1';

  Future<List<NoteEntry>> loadNotes() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_storageKey);

    if (storedValue == null || storedValue.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedValue);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => NoteEntry.fromJson(Map<String, dynamic>.from(item)))
          .where((note) => note.id.isNotEmpty)
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveNotes(List<NoteEntry> notes) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(notes.map((note) => note.toJson()).toList());

    final saved = await preferences.setString(_storageKey, encoded);

    if (!saved) {
      throw StateError('The notes could not be saved.');
    }
  }
}
