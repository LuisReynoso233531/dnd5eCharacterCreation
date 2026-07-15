import '../data/models/subclass_spell_grant.dart';

class SubclassSpellParser {
  const SubclassSpellParser._();

  static List<SubclassSpellTable> parse(String? description) {
    if (description == null || description.trim().isEmpty) {
      return const [];
    }

    final lines = description.split('\n');
    final tables = <SubclassSpellTable>[];
    String lastHeading = '';
    String lastBoldTitle = '';

    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();

      if (!trimmed.startsWith('|')) {
        final headingMatch = RegExp(r'^#{2,6}\s+(.+)$').firstMatch(trimmed);
        if (headingMatch != null) {
          lastHeading = _cleanMarkdown(headingMatch.group(1) ?? '');
          lastBoldTitle = '';
          continue;
        }

        if (_looksLikeStandaloneBoldTitle(trimmed)) {
          lastBoldTitle = _cleanMarkdown(trimmed);
        }
        continue;
      }

      if (i + 1 >= lines.length || !_isSeparatorRow(lines[i + 1])) {
        continue;
      }

      final headers = _cells(trimmed);
      if (headers.isEmpty) continue;

      final normalizedHeaders = headers.map((h) => h.toLowerCase()).toList();

      // Las tablas de progresión indican cantidades, no hechizos fijos.
      if (normalizedHeaders.any(
        (h) => h.contains('spells known') || h.contains('cantrips known'),
      )) {
        continue;
      }

      final levelColumn = normalizedHeaders.indexWhere(
        (h) => h == 'level' || h.endsWith(' level'),
      );
      if (levelColumn < 0) continue;

      // En las tablas de patrono de warlock, "Spell Level" representa el
      // nivel del conjuro y la lista solo amplía las opciones disponibles.
      if (normalizedHeaders[levelColumn] == 'spell level') {
        continue;
      }

      final spellColumns = <int>[];
      for (int column = 0; column < normalizedHeaders.length; column++) {
        final header = normalizedHeaders[column];
        if (header.contains('spell') &&
            !header.contains('known') &&
            !header.contains('slot') &&
            header != 'spell level') {
          spellColumns.add(column);
        }
      }
      if (spellColumns.isEmpty) continue;

      final contextStart = i - 5 < 0 ? 0 : i - 5;
      final nearbyContext = lines
          .sublist(contextStart, i)
          .join(' ')
          .toLowerCase();
      final titleContext = '$lastHeading $lastBoldTitle'.toLowerCase();

      // "Expanded Spell List" no concede hechizos automáticamente.
      if (nearbyContext.contains('expanded spell') ||
          titleContext.contains('expanded spell')) {
        continue;
      }

      final title = lastBoldTitle.isNotEmpty
          ? lastBoldTitle
          : lastHeading.isNotEmpty
          ? lastHeading
          : headers[spellColumns.first];

      final grants = <SubclassSpellGrant>[];
      int rowIndex = i + 2;

      while (rowIndex < lines.length && lines[rowIndex].trim().startsWith('|')) {
        final row = _cells(lines[rowIndex]);
        rowIndex++;

        if (row.length <= levelColumn) continue;
        final characterLevel = _parseLevel(row[levelColumn]);
        if (characterLevel == null) continue;

        for (final spellColumn in spellColumns) {
          if (spellColumn >= row.length) continue;
          for (final spellName in _splitSpellNames(row[spellColumn])) {
            grants.add(
              SubclassSpellGrant(
                characterLevel: characterLevel,
                spellName: spellName,
              ),
            );
          }
        }
      }

      if (grants.isNotEmpty) {
        final cleanTitle = title
            .replaceAll(RegExp(r'\s*\(table\)\s*$', caseSensitive: false), '')
            .trim();
        tables.add(
          SubclassSpellTable(
            id: '${_slugify(cleanTitle)}-${tables.length}',
            title: cleanTitle,
            grants: _deduplicate(grants),
          ),
        );
      }

      i = rowIndex - 1;
    }

    return tables;
  }

  static bool _looksLikeStandaloneBoldTitle(String value) {
    if (value.isEmpty) return false;
    return RegExp(r'^(\*\*|__|\*\*\*|___).+(\*\*|__|\*\*\*|___)$')
        .hasMatch(value);
  }

  static bool _isSeparatorRow(String value) {
    final cells = _cells(value);
    return cells.isNotEmpty &&
        cells.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
  }

  static List<String> _cells(String line) {
    var value = line.trim();
    if (value.startsWith('|')) value = value.substring(1);
    if (value.endsWith('|')) value = value.substring(0, value.length - 1);
    return value.split('|').map((cell) => cell.trim()).toList();
  }

  static int? _parseLevel(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  static List<String> _splitSpellNames(String value) {
    final clean = _cleanMarkdown(value)
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ',')
        .replaceAll(';', ',');

    return clean
        .split(',')
        .map((name) => name.trim())
        .where((name) =>
            name.isNotEmpty && name != '-' && name.toLowerCase() != 'none')
        .toList(growable: false);
  }

  static String _cleanMarkdown(String value) {
    return value
        .replaceAll(RegExp(r'[*_`]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _slugify(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'subclass-spells' : slug;
  }

  static List<SubclassSpellGrant> _deduplicate(
    List<SubclassSpellGrant> grants,
  ) {
    final result = <SubclassSpellGrant>[];
    final seen = <String>{};

    for (final grant in grants) {
      final key =
          '${grant.characterLevel}:${grant.spellName.toLowerCase().trim()}';
      if (seen.add(key)) result.add(grant);
    }

    return result;
  }
}
