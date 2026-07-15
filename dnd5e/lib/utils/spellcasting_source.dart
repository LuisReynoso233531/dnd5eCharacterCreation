import '../data/models/character_class.dart';

class SpellcastingSource {
  final String table;
  final String ability;
  final String spellListSlug;
  final String apiClassName;
  final String rulesSlug;
  final String displayName;
  final bool comesFromSubclass;

  const SpellcastingSource({
    required this.table,
    required this.ability,
    required this.spellListSlug,
    required this.apiClassName,
    required this.rulesSlug,
    required this.displayName,
    required this.comesFromSubclass,
  });

  bool hasSpellSelectionAtLevel(int characterLevel) {
    final lines = table
        .split('\n')
        .where((line) => line.trim().startsWith('|'))
        .toList();

    if (lines.length < 3) return false;

    final headers = _cells(lines.first);
    final levelText = _ordinal(characterLevel).toLowerCase();

    for (final line in lines.skip(2)) {
      final columns = _cells(line);
      if (columns.isEmpty) continue;

      final rowLevel = columns.first.toLowerCase();
      if (rowLevel != levelText && rowLevel != '$characterLevel') continue;

      for (int i = 1; i < headers.length && i < columns.length; i++) {
        final header = headers[i].toLowerCase();
        final isSpellQuantity =
            header.contains('cantrips known') ||
            header.contains('spells known') ||
            header.contains('spell slots') ||
            RegExp(r'^\d+(st|nd|rd|th)$').hasMatch(header);

        if (!isSpellQuantity) continue;

        final value = int.tryParse(columns[i].replaceAll('+', '').trim()) ?? 0;
        if (value > 0) return true;
      }
    }

    return false;
  }

  static List<String> _cells(String line) {
    var value = line.trim();
    if (value.startsWith('|')) value = value.substring(1);
    if (value.endsWith('|')) value = value.substring(0, value.length - 1);
    return value.split('|').map((cell) => cell.trim()).toList();
  }

  static String _ordinal(int number) {
    final mod100 = number % 100;
    if (mod100 >= 11 && mod100 <= 13) return '${number}th';

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

class SpellcastingSourceResolver {
  const SpellcastingSourceResolver._();

  static const Set<String> _baseSpellcasters = {
    'bard',
    'cleric',
    'druid',
    'paladin',
    'ranger',
    'sorcerer',
    'warlock',
    'wizard',
  };

  static SpellcastingSource? resolve({
    required CharacterClass characterClass,
    required int characterLevel,
    Map<String, dynamic>? archetype,
  }) {
    final classSlug = characterClass.slug.toLowerCase();

    if (_baseSpellcasters.contains(classSlug)) {
      final table = characterClass.table?.trim() ?? '';
      if (table.isEmpty) return null;

      return SpellcastingSource(
        table: table,
        ability: characterClass.spellcasting_ability,
        spellListSlug: classSlug,
        apiClassName: characterClass.name,
        rulesSlug: classSlug,
        displayName: characterClass.name,
        comesFromSubclass: false,
      );
    }

    if (archetype == null) return null;

    final description = archetype['desc']?.toString() ?? '';
    final table = _extractSpellcastingProgressionTable(description);
    if (table == null) return null;

    final spellListSlug = _extractSpellListSlug(description) ?? 'wizard';
    final ability = _extractSpellcastingAbility(description) ?? 'Intelligence';
    final displayName = archetype['name']?.toString().trim();

    final source = SpellcastingSource(
      table: table,
      ability: ability,
      spellListSlug: spellListSlug,
      apiClassName: _titleCase(spellListSlug),
      rulesSlug: classSlug,
      displayName: displayName?.isNotEmpty == true
          ? displayName!
          : characterClass.name,
      comesFromSubclass: true,
    );

    return source.hasSpellSelectionAtLevel(characterLevel) ? source : null;
  }

  static String? _extractSpellcastingProgressionTable(String description) {
    final lines = description.split('\n');

    for (int i = 0; i < lines.length - 1; i++) {
      if (!lines[i].trim().startsWith('|')) continue;
      if (!_isSeparatorRow(lines[i + 1])) continue;

      final tableLines = <String>[lines[i], lines[i + 1]];
      int row = i + 2;
      while (row < lines.length && lines[row].trim().startsWith('|')) {
        tableLines.add(lines[row]);
        row++;
      }

      final headers = SpellcastingSource._cells(lines[i])
          .map((header) => header.toLowerCase())
          .toList();

      final hasKnownColumn = headers.any(
        (header) =>
            header.contains('cantrips known') ||
            header.contains('spells known'),
      );
      final hasSlots = headers.any(
        (header) => RegExp(r'^\d+(st|nd|rd|th)$').hasMatch(header),
      );

      if (hasKnownColumn && hasSlots) {
        return tableLines.join('\n');
      }

      i = row - 1;
    }

    return null;
  }

  static String? _extractSpellListSlug(String description) {
    final match = RegExp(
      r'from\s+the\s+([a-z]+)\s+spell\s+list',
      caseSensitive: false,
    ).firstMatch(description);

    return match?.group(1)?.toLowerCase();
  }

  static String? _extractSpellcastingAbility(String description) {
    final leadingAbility = RegExp(
      r'\b(intelligence|wisdom|charisma)\s+is\s+your\s+'
      r'spellcasting ability',
      caseSensitive: false,
    ).firstMatch(description);

    if (leadingAbility != null) {
      return _titleCase(leadingAbility.group(1)!);
    }

    final explicit = RegExp(
      r'spellcasting ability[^.\n]{0,140}\bis\s+'
      r'(intelligence|wisdom|charisma)',
      caseSensitive: false,
    ).firstMatch(description);

    if (explicit != null) return _titleCase(explicit.group(1)!);

    final modifier = RegExp(
      r'use your\s+(intelligence|wisdom|charisma)\s+modifier',
      caseSensitive: false,
    ).firstMatch(description);

    return modifier == null ? null : _titleCase(modifier.group(1)!);
  }

  static bool _isSeparatorRow(String line) {
    final cells = SpellcastingSource._cells(line);
    return cells.isNotEmpty &&
        cells.every((cell) => RegExp(r'^:?-{3,}:?$').hasMatch(cell));
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
