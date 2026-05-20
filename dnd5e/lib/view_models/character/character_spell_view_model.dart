import 'package:flutter/material.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/models/spell_model.dart';

// ─── ViewModel ───────────────────────────────────────────────────────────────
class CharacterSpellViewModel extends ChangeNotifier {
  final CharacterRepository _repository; 
  CharacterSpellViewModel(this._repository);

  // Estado de carga
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _loadedPages = 0;
  int _totalPages = 0;
  double get loadProgress => _totalPages == 0 ? 0 : _loadedPages / _totalPages;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isFullyLoaded => _loadedPages >= _totalPages && _totalPages > 0;
  String? get error => _error;
  // Hechizos disponibles (del API)
  List<SpellModel> _allSpells = [];
  List<SpellModel> get allSpells => _allSpells;

  // Hechizos seleccionados por nivel (0 = cantrips)
  // Key: spell level (0–9), Value: lista de slugs seleccionados
  final Map<int, List<String>> _selectedSpells = {};
  Map<int, List<String>> get selectedSpells => _selectedSpells;

  // Filtro de búsqueda
  String _searchQuery = '';
  int _filterLevel = -1; // -1 = todos
  String get searchQuery => _searchQuery;
  int get filterLevel => _filterLevel;

  // Tab activo en la UI (nivel de hechizo)
  int _activeTab = 0;
  int get activeTab => _activeTab;
  int get totalNonCantripSelected =>
    _selectedSpells.entries
        .where((e) => e.key > 0)
        .fold(0, (sum, e) => sum + e.value.length);
  
  int get totalCantripsSelected => (_selectedSpells[0] ?? []).length;
  bool canAddMoreSpells(int globalMax) => totalNonCantripSelected < globalMax;

  // ─── Carga de hechizos ────────────────────────────────────────────────────
Future<void> loadSpells(String dndClass) async {
  if (_allSpells.isNotEmpty) return; // Ya cargados
  
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // 1. Cargar página 1 inmediatamente pasando la clase
    final firstPage = await _repository.getSpells(dndClass, page: 1);
    _allSpells = firstPage.map((j) => SpellModel.fromJson(j)).toList();
    _loadedPages = 1;
    _isLoading = false;
    notifyListeners(); // La UI ya muestra la primera tanda rápidamente

    // 2. Obtener total de páginas filtradas por dndClass
    _totalPages = await _repository.getSpellsPageCount(dndClass);
    
    if (_totalPages <= 1) return;

    // 3. Cargar el resto en paralelo por batches de 5
    _isLoadingMore = true;
    notifyListeners();

    // Genera el listado restante, ej: si total son 3 páginas, genera [2, 3]
    final remainingPages = List.generate(_totalPages - 1, (i) => i + 2); 

    const batchSize = 5;
    for (int i = 0; i < remainingPages.length; i += batchSize) {
      final batch = remainingPages.skip(i).take(batchSize).toList();

      // Las páginas del batch se cargan en paralelo pasando la clase obligatoria
      final results = await Future.wait(
        batch.map((page) => _repository.getSpells(dndClass, page: page)),
      );

      for (final pageData in results) {
        _allSpells.addAll(pageData.map((j) => SpellModel.fromJson(j)));
        _loadedPages++;
      }

      // Ordenar y notificar después de cada batch terminado
      _allSpells.sort((a, b) {
        final lvl = a.levelInt.compareTo(b.levelInt);
        return lvl != 0 ? lvl : a.name.compareTo(b.name);
      });

      notifyListeners(); // Actualización progresiva en la UI
    }
  } catch (e) {
    _error = 'Error al cargar hechizos: $e';
    notifyListeners();
  } finally {
    _isLoadingMore = false;
    notifyListeners();
  }
}
  // ─── Parser de tabla de clase ─────────────────────────────────────────────
  /// Extrae SpellcastingInfo para un nivel dado de la tabla de la clase.
  SpellcastingInfo? parseSpellcastingInfo(
    String? table,
    String slug,
    int level,
  ) {
    if (table == null || table.isEmpty) return null;

    final lines = table
        .split('\n')
        .where((l) => l.trim().startsWith('|'))
        .toList();
    if (lines.length < 2) return null;

    final headers = lines[0]
        .split('|')
        .map((h) => h.trim())
        .where((h) => h.isNotEmpty)
        .toList();

    // Buscar fila del nivel actual
    final levelStr = _levelOrdinal(level);
    Map<String, String>? rowData;
    for (final line in lines.skip(2)) {
      final cols = line
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cols.isEmpty) continue;
      final rowLevel = cols[0].toLowerCase().trim();
      if (rowLevel == levelStr.toLowerCase() || rowLevel == '$level') {
        rowData = {
          for (int i = 0; i < headers.length && i < cols.length; i++)
            headers[i]: cols[i],
        };
        break;
      }
    }
    if (rowData == null) return null;

    int parseVal(String? v) => int.tryParse(v?.replaceAll('+', '') ?? '') ?? 0;

    // Espacios de conjuro (niveles 1–9)
    final slots = List.filled(9, 0);
    for (int i = 1; i <= 9; i++) {
      final key = _levelOrdinal(i);
      if (rowData.containsKey(key)) {
        slots[i - 1] = parseVal(rowData[key]);
      }
    }

    // Warlock: sistema especial
    if (slug == 'warlock') {
      final wSlots = parseVal(rowData['Spell Slots']);
      final wLevelStr = rowData['Slot Level'] ?? '1st';
      final wLevel = _ordinalToInt(wLevelStr);
      return SpellcastingInfo(
        spellsKnown: parseVal(rowData['Spells Known']),
        cantripsKnown: parseVal(rowData['Cantrips Known']),
        slotsPerLevel: slots,
        warlockSlots: wSlots,
        warlockSlotLevel: wLevel,
      );
    }

    return SpellcastingInfo(
      spellsKnown: rowData.containsKey('Spells Known')
          ? parseVal(rowData['Spells Known'])
          : null,
      cantripsKnown: parseVal(rowData['Cantrips Known']),
      slotsPerLevel: slots,
    );
  }

  // ─── Cuántos hechizos puede aprender (fórmula dinámica) ──────────────────
  /// Para clases con fórmula basada en stats.
  /// [statMod]: modificador de la característica de conjuro.
  int dynamicSpellsKnown(String slug, int level, int statMod) {
    switch (slug) {
      case 'cleric':
      case 'druid':
        return level + statMod;
      case 'wizard':
        // 6 iniciales + (nivel + Int) al nivel 1, +2 por nivel adicional
        return 6 + level + statMod + (level > 1 ? (level - 1) * 2 : 0);
      case 'paladin':
        return (level / 2).floor() + statMod;
      default:
        return 0;
    }
  }

  /// Si la clase usa fórmula dinámica (no hardcoded de la tabla).
  bool usesDynamicFormula(String slug) =>
      ['cleric', 'druid', 'wizard', 'paladin'].contains(slug);

  /// Si la clase tiene hechizos en absoluto.
  bool isSpellcaster(String slug) => [
    'bard', 'cleric', 'druid', 'paladin', 'ranger',
    'sorcerer', 'warlock', 'wizard',
    // Subclases (rogue arcane trickster, fighter eldritch knight)
    // se manejan con el slug 'rogue' y 'fighter' + archetype check
  ].contains(slug);

  // ─── Hechizos filtrados para la UI ────────────────────────────────────────
  List<SpellModel> filteredSpells(String classSlug, int maxLevel) {
    return _allSpells.where((s) {
      // Filtrar por clase
      final classMatch =
          s.dndClass.toLowerCase().contains(classSlug.toLowerCase()) ||
          _classAliases(
            classSlug,
          ).any((alias) => s.dndClass.toLowerCase().contains(alias));
      if (!classMatch) return false;

      // Filtrar por nivel máximo permitido
      if (s.levelInt > maxLevel) return false;

      // Filtrar por búsqueda
      if (_searchQuery.isNotEmpty &&
          !s.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Filtrar por nivel seleccionado
      if (_filterLevel >= 0 && s.levelInt != _filterLevel) return false;

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
      'rogue': ['wizard', 'sorcerer'], // arcane trickster
      'fighter': ['wizard'], // eldritch knight
    };
    return aliases[slug] ?? [slug];
  }

  // ─── Gestión de selección ──────────────────────────────────────────────────
  void toggleSpell(String slug, int spellLevel, int globalMax) {
  // Cantrips tienen su propio sistema
  assert(spellLevel > 0, 'Use toggleCantrip for cantrips');

  final list = _selectedSpells[spellLevel] ??= [];

  if (list.contains(slug)) {
    // Siempre se puede deseleccionar
    list.remove(slug);
  } else {
    // Solo añadir si no se superó el pool global
    if (totalNonCantripSelected >= globalMax) return;
    list.add(slug);
  }
  notifyListeners();
}

  void toggleCantrip(String slug, int maxCantrips) {
  final list = _selectedSpells[0] ??= [];
  if (list.contains(slug)) {
    list.remove(slug);
  } else if (list.length < maxCantrips) {
    list.add(slug);
  }
  notifyListeners();
}

bool isSelected(String slug, int spellLevel) =>
    (_selectedSpells[spellLevel] ?? []).contains(slug);

  int totalSelectedAcrossAllLevels() =>
      _selectedSpells.values.fold(0, (sum, list) => sum + list.length);

int selectedCountForLevel(int level) =>
    (_selectedSpells[level] ?? []).length;

List<SpellModel> getSelectedSpellModels() {
  final slugs = _selectedSpells.values.expand((l) => l).toSet();
  return _allSpells.where((s) => slugs.contains(s.slug)).toList();
}

  // ─── UI state ─────────────────────────────────────────────────────────────
  void setSearchQuery(String q) {
    _searchQuery = q;
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
    _searchQuery = '';
    _filterLevel = -1;
    _activeTab = 0;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _levelOrdinal(int n) {
    switch (n) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${n}th';
    }
  }

  int _ordinalToInt(String s) {
    final n = int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
    return n ?? 1;
  }
}
