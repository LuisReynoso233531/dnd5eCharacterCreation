import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SavedCharacterSheet {
  final String name;
  final String path;
  final DateTime modifiedAt;
  final int sizeBytes;

  const SavedCharacterSheet({
    required this.name,
    required this.path,
    required this.modifiedAt,
    required this.sizeBytes,
  });

  String get displayName {
    return name.replaceAll('.pdf', '').replaceAll('_', ' ');
  }
}

class CharacterSheetStorage {
  static const String _folderName = 'character_sheets';

  static Future<Directory> sheetsDirectory() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/$_folderName');

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return dir;
  }

  static Future<String> createPdfPath(String characterName) async {
    final dir = await sheetsDirectory();

    final safeName = characterName.trim().isEmpty
        ? 'character'
        : characterName
            .trim()
            .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
            .replaceAll(RegExp(r'\s+'), '_');

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');

    return '${dir.path}/${safeName}_$timestamp.pdf';
  }

  static Future<List<SavedCharacterSheet>> listSheets() async {
    final dir = await sheetsDirectory();

    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.pdf'))
        .cast<File>()
        .toList();

    final sheets = <SavedCharacterSheet>[];

    for (final file in files) {
      final stat = await file.stat();

      sheets.add(
        SavedCharacterSheet(
          name: file.uri.pathSegments.last,
          path: file.path,
          modifiedAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }

    sheets.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));

    return sheets;
  }

  static Future<void> deleteSheet(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}