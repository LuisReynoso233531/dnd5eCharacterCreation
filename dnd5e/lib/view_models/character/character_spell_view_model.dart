import 'package:flutter/material.dart';
import '../../data/models/spell_model.dart';
import '../../data/models/subclass_spell_grant.dart';
import '../../data/repositories/character_repository.dart';

class CharacterSpellViewModel extends ChangeNotifier {
  final CharacterRepository _repository;
  CharacterSpellViewModel(this._repository);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _loadedPages = 0;
  int _totalPages = 0;

  double get loadProgress =>
      _totalPages == 0 ? 0 : _loadedPages / _totalPages;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isFullyLoaded =>
      !_isLoading && !_isLoadingMore && (_totalPages == 0 || _loadedPages >= _totalPages);
  String? get error => _error;

  List<SpellModel> _allSpells = [];
  List<SpellModel> get allSpells => List.unmodifiable(_allSpells);

  // Hechizos elegidos manualmente. Estos sí consumen el límite de la clase.
  final Map<int, List<String>> _selectedSpells = {};
  Map<int, List<String>> get selectedSpells => _selectedSpells;

  // Hechizos concedidos por subclase. No consumen el límite y no se eliminan.
  final Map<int, List<String>> _automaticSpells = {};
  Map<int, List<String>> get automaticSpells => _automaticSpells;

  final Set<String> _automaticSpellNames = {};
  Set<String> get automaticSpellNames => Set.unmodifiable(_automaticSpellNames);

  // Automáticos que sí forman parte del número conocido de la tabla.
  // Ejemplo: Mage Hand del Eldritch Trickster.
  final Set<String> _automaticSpellsCountingAgainstLimit = {};

  final List<String> _unresolvedAutomaticSpellNames = [];
  List<String> get unresolvedAutomaticSpellNames =>
      List.unmodifiable(_unresolvedAutomaticSpellNames);

  String _searchQuery = '';
  int _filterLevel = -1;
  String get searchQuery => _searchQuery;
  int get filterLevel => _filterLevel;

  int _activeTab = 0;
  int get activeTab => _activeTab;

  int get totalNonCantripSelected => _selectedSpells.entries
      .where((entry) => entry.key > 0)
      .fold(0, (sum, entry) => sum + entry.value.length);

  int get totalCantripsSelected => (_selectedSpells[0] ?? []).length;

  int get totalAutomaticSpells =>
      _automaticSpells.values.fold(0, (sum, list) => sum + list.length);

  int get automaticCantripsCountingAgainstLimit =>
      (_automaticSpells[0] ?? const [])
          .where(_automaticSpellsCountingAgainstLimit.contains)
          .length;

  int get automaticNonCantripsCountingAgainstLimit => _automaticSpells.entries
      .where((entry) => entry.key > 0)
      .expand((entry) => entry.value)
      .where(_automaticSpellsCountingAgainstLimit.contains)
      .length;

  int get totalCantripsTowardLimit =>
      totalCantripsSelected + automaticCantripsCountingAgainstLimit;

  int get totalNonCantripsTowardLimit =>
      totalNonCantripSelected + automaticNonCantripsCountingAgainstLimit;

  bool canAddMoreSpells(int globalMax) =>
      totalNonCantripsTowardLimit < globalMax;

  Future<void> loadSpells(
    String dndClass, {
    List<SubclassSpellGrant> automaticGrants = const [],
    String? preferredDocumentSlug,
  }) async {
    if (_allSpells.isEmpty) {
      await _loadClassSpells(dndClass);
    }

    await setAutomaticSpells(
      automaticGrants,
      preferredDocumentSlug: preferredDocumentSlug,
    );
  }

  Future<void> _loadClassSpells(String dndClass) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final firstPage = await _repository.getSpells(dndClass, page: 1);
      _allSpells = firstPage.map((json) => SpellModel.fromJson(json)).toList();
      _loadedPages = firstPage.isEmpty ? 0 : 1;
      _isLoading = false;
      notifyListeners();

      _totalPages = await _repository.getSpellsPageCount(dndClass);
      if (_totalPages <= 1) return;

      _isLoadingMore = true;
      notifyListeners();

      final remainingPages = List.generate(
        _totalPages - 1,
        (index) => index + 2,
      );

      const batchSize = 5;
      for (int i = 0; i < remainingPages.length; i += batchSize) {
        final batch = remainingPages.skip(i).take(batchSize).toList();
        final results = await Future.wait(
          batch.map((page) => _repository.getSpells(dndClass, page: page)),
        );

        for (final pageData in results) {
          _allSpells.addAll(pageData.map((json) => SpellModel.fromJson(json)));
          _loadedPages++;
        }

        _sortSpells();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al cargar hechizos: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> setAutomaticSpells(
    List<SubclassSpellGrant> grants, {
    String? preferredDocumentSlug,
  }) async {
    _automaticSpells.clear();
    _automaticSpellNames.clear();
    _automaticSpellsCountingAgainstLimit.clear();
    _unresolvedAutomaticSpellNames.clear();

    if (grants.isEmpty) {
      notifyListeners();
      return;
    }

    final uniqueGrants = <String, SubclassSpellGrant>{};
    for (final grant in grants) {
      final key = _normalizeName(grant.spellName);
      if (key.isNotEmpty) uniqueGrants.putIfAbsent(key, () => grant);
    }

    _automaticSpellNames.addAll(uniqueGrants.keys);

    final loadedNames = {
      for (final spell in _allSpells) _normalizeName(spell.name),
    };
    final missingNames = uniqueGrants.entries
        .where((entry) => !loadedNames.contains(entry.key))
        .map((entry) => entry.value.spellName)
        .toList();

    if (missingNames.isNotEmpty) {
      final fetched = await _repository.getSpellsByNames(
        missingNames,
        preferredDocumentSlug: preferredDocumentSlug,
      );

      final existingSlugs = _allSpells.map((spell) => spell.slug).toSet();
      for (final json in fetched) {
        final spell = SpellModel.fromJson(json);
        if (spell.slug.isNotEmpty && existingSlugs.add(spell.slug)) {
          _allSpells.add(spell);
        }
      }
    }

    final modelsByName = <String, SpellModel>{};
    for (final spell in _allSpells) {
      modelsByName.putIfAbsent(_normalizeName(spell.name), () => spell);
    }

    for (final entry in uniqueGrants.entries) {
      final spell = modelsByName[entry.key];
      if (spell == null) {
        _unresolvedAutomaticSpellNames.add(entry.value.spellName);
        continue;
      }

      final slugs = _automaticSpells[spell.levelInt] ??= [];
      if (!slugs.contains(spell.slug)) slugs.add(spell.slug);

      if (entry.value.countsAgainstLimit) {
        _automaticSpellsCountingAgainstLimit.add(spell.slug);
      }

      // Si ya se había elegido manualmente, deja de consumir cupo.
      for (final selected in _selectedSpells.values) {
        selected.remove(spell.slug);
      }
    }

    _selectedSpells.removeWhere((_, slugs) => slugs.isEmpty);
    _sortSpells();
    notifyListeners();
  }

  SpellcastingInfo? parseSpellcastingInfo(
    String? table,
    String slug,
    int level,
  ) {
    if (table == null || table.isEmpty) return null;

    final lines = table
        .split('\n')
        .where((line) => line.trim().startsWith('|'))
        .toList();
    if (lines.length < 2) return null;

    final headers = lines[0]
        .split('|')
        .map((header) => header.trim())
        .where((header) => header.isNotEmpty)
        .toList();

    final levelString = _levelOrdinal(level);
    Map<String, String>? rowData;

    for (final line in lines.skip(2)) {
      final columns = line
          .split('|')
          .map((column) => column.trim())
          .where((column) => column.isNotEmpty)
          .toList();
      if (columns.isEmpty) continue;

      final rowLevel = columns[0].toLowerCase().trim();
      if (rowLevel == levelString.toLowerCase() || rowLevel == '$level') {
        rowData = {
          for (int i = 0; i < headers.length && i < columns.length; i++)
            headers[i]: columns[i],
        };
        break;
      }
    }

    if (rowData == null) return null;

    int parseValue(String? value) =>
        int.tryParse(value?.replaceAll('+', '') ?? '') ?? 0;

    final slots = List.filled(9, 0);
    for (int i = 1; i <= 9; i++) {
      final key = _levelOrdinal(i);
      if (rowData.containsKey(key)) {
        slots[i - 1] = parseValue(rowData[key]);
      }
    }

    if (slug == 'warlock') {
      final warlockSlots = parseValue(rowData['Spell Slots']);
      final warlockLevel = _ordinalToInt(rowData['Slot Level'] ?? '1st');
      return SpellcastingInfo(
        spellsKnown: parseValue(rowData['Spells Known']),
        cantripsKnown: parseValue(rowData['Cantrips Known']),
        slotsPerLevel: slots,
        warlockSlots: warlockSlots,
        warlockSlotLevel: warlockLevel,
      );
    }

    return SpellcastingInfo(
      spellsKnown: rowData.containsKey('Spells Known')
          ? parseValue(rowData['Spells Known'])
          : null,
      cantripsKnown: parseValue(rowData['Cantrips Known']),
      slotsPerLevel: slots,
    );
  }

  int dynamicSpellsKnown(String slug, int level, int statMod) {
    switch (slug) {
      case 'cleric':
      case 'druid':
        return level + statMod;
      case 'wizard':
        return 6 + level + statMod + (level > 1 ? (level - 1) * 2 : 0);
      case 'paladin':
        return (level / 2).floor() + statMod;
      default:
        return 0;
    }
  }

  bool usesDynamicFormula(String slug) =>
      ['cleric', 'druid', 'wizard', 'paladin'].contains(slug);

  bool isSpellcaster(String slug) => [
    'bard',
    'cleric',
    'druid',
    'paladin',
    'ranger',
    'sorcerer',
    'warlock',
    'wizard',
  ].contains(slug);

  List<SpellModel> filteredSpells(String classSlug, int maxLevel) {
    return _allSpells.where((spell) {
      final automatic = isAutomaticSpell(spell.slug);
      final classMatch =
          spell.dndClass.toLowerCase().contains(classSlug.toLowerCase()) ||
          _classAliases(classSlug).any(
            (alias) => spell.dndClass.toLowerCase().contains(alias),
          );

      if (!automatic && !classMatch) return false;
      if (spell.levelInt > maxLevel) return false;

      if (_searchQuery.isNotEmpty &&
          !spell.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      if (_filterLevel >= 0 && spell.levelInt != _filterLevel) return false;
      return true;
    }).toList();
  }

  List<String> _classAliases(String slug) {
    const aliases = {
      'bard': ['bard'],
      'cleric': ['cleric'],
      'druid': ['druid'],
      'paladin': ['paladin'],
      'ranger': ['ranger'],
      'sorcerer': ['sorcerer'],
      'warlock': ['warlock'],
      'wizard': ['wizard'],
      'rogue': ['wizard', 'sorcerer'],
      'fighter': ['wizard'],
    };
    return aliases[slug] ?? [slug];
  }

  void toggleSpell(String slug, int spellLevel, int globalMax) {
    assert(spellLevel > 0, 'Use toggleCantrip for cantrips');
    if (isAutomaticSpell(slug)) return;

    final list = _selectedSpells[spellLevel] ??= [];
    if (list.contains(slug)) {
      list.remove(slug);
    } else if (totalNonCantripsTowardLimit < globalMax) {
      list.add(slug);
    }

    if (list.isEmpty) _selectedSpells.remove(spellLevel);
    notifyListeners();
  }

  void toggleCantrip(String slug, int maxCantrips) {
    if (isAutomaticSpell(slug)) return;

    final list = _selectedSpells[0] ??= [];
    if (list.contains(slug)) {
      list.remove(slug);
    } else if (totalCantripsTowardLimit < maxCantrips) {
      list.add(slug);
    }

    if (list.isEmpty) _selectedSpells.remove(0);
    notifyListeners();
  }

  bool isAutomaticSpell(String slug) =>
      _automaticSpells.values.any((slugs) => slugs.contains(slug));

  bool isSelected(String slug, int spellLevel) =>
      (_selectedSpells[spellLevel] ?? []).contains(slug) ||
      (_automaticSpells[spellLevel] ?? []).contains(slug);

  int totalSelectedAcrossAllLevels() {
    final slugs = <String>{};
    slugs.addAll(_selectedSpells.values.expand((list) => list));
    slugs.addAll(_automaticSpells.values.expand((list) => list));
    return slugs.length;
  }

  int selectedCountForLevel(int level) {
    final slugs = <String>{
      ...?_selectedSpells[level],
      ...?_automaticSpells[level],
    };
    return slugs.length;
  }

  List<SpellModel> getAutomaticSpellModels() {
    final slugs = _automaticSpells.values.expand((list) => list).toSet();
    return _allSpells.where((spell) => slugs.contains(spell.slug)).toList();
  }

  List<SpellModel> getSelectedSpellModels() {
    final slugs = <String>{};
    slugs.addAll(_selectedSpells.values.expand((list) => list));
    slugs.addAll(_automaticSpells.values.expand((list) => list));
    return _allSpells.where((spell) => slugs.contains(spell.slug)).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterLevel(int level) {
    _filterLevel = level;
    notifyListeners();
  }

  void setActiveTab(int tab) {
    _activeTab = tab;
    notifyListeners();
  }

  void reset() {
    _selectedSpells.clear();
    _automaticSpells.clear();
    _automaticSpellNames.clear();
    _automaticSpellsCountingAgainstLimit.clear();
    _unresolvedAutomaticSpellNames.clear();
    _searchQuery = '';
    _filterLevel = -1;
    _activeTab = 0;
    notifyListeners();
  }

  void _sortSpells() {
    _allSpells.sort((a, b) {
      final levelComparison = a.levelInt.compareTo(b.levelInt);
      return levelComparison != 0
          ? levelComparison
          : a.name.compareTo(b.name);
    });
  }

  String _normalizeName(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[*_`]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String _levelOrdinal(int number) {
    switch (number) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${number}th';
    }
  }

  int _ordinalToInt(String value) {
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    return number ?? 1;
  }
}
