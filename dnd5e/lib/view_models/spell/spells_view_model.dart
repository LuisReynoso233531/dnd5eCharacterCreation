import 'package:flutter/foundation.dart';

import '../../data/repositories/spells_repository.dart';

class SpellsViewModel extends ChangeNotifier {
  SpellsViewModel({SpellsRepository? repository})
    : _repository = repository ?? SpellsRepository() {
    loadSpells();
  }

  final SpellsRepository _repository;

  List<Map<String, dynamic>> _allSpells = [];
  List<Map<String, dynamic>> _filteredSpells = [];
  List<String> _availableClasses = [];

  final Set<String> _selectedClasses = {};

  bool _isLoading = false;
  String _searchQuery = '';
  String? _errorMessage;

  List<Map<String, dynamic>> get filteredSpells {
    return List.unmodifiable(_filteredSpells);
  }

  List<String> get availableClasses {
    return List.unmodifiable(_availableClasses);
  }

  Set<String> get selectedClasses {
    return Set.unmodifiable(_selectedClasses);
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasClassFilters => _selectedClasses.isNotEmpty;

  Future<void> loadSpells() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final spells = await _repository.getSpells();

      spells.sort((first, second) {
        final firstName = (first['name'] ?? '').toString().toLowerCase();

        final secondName = (second['name'] ?? '').toString().toLowerCase();

        if (spells.isNotEmpty) {
          debugPrint(
            'SPELL CLASS DATA: '
            '${spells.first['dnd_class']}',
          );
        }

        return firstName.compareTo(secondName);
      });

      _allSpells = spells;
      _availableClasses = _extractAvailableClasses(spells);

      // Elimina filtros que ya no existan en los datos cargados.
      _selectedClasses.removeWhere(
        (className) => !_availableClasses.contains(className),
      );

      _applyFilters(notify: false);
    } catch (error) {
      _allSpells = [];
      _filteredSpells = [];
      _availableClasses = [];
      _errorMessage = error.toString();

      debugPrint('Error loading spells: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void toggleClass(String className) {
    if (_selectedClasses.contains(className)) {
      _selectedClasses.remove(className);
    } else {
      _selectedClasses.add(className);
    }

    _applyFilters();
  }

  void clearClassFilters() {
    if (_selectedClasses.isEmpty) {
      return;
    }

    _selectedClasses.clear();
    _applyFilters();
  }

  bool isClassSelected(String className) {
    return _selectedClasses.contains(className);
  }

  List<Map<String, dynamic>> spellsForLevel(int level) {
    return _filteredSpells
        .where((spell) => _spellLevel(spell) == level)
        .toList(growable: false);
  }

  void _applyFilters({bool notify = true}) {
    _filteredSpells = _allSpells.where((spell) {
      final name = (spell['name'] ?? '').toString().toLowerCase();

      final slug = (spell['slug'] ?? '').toString().toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          slug.contains(_searchQuery);

      if (!matchesSearch) {
        return false;
      }

      if (_selectedClasses.isEmpty) {
        return true;
      }

      final spellClasses = _classesForSpell(
        spell,
      ).map(_normalizeClassName).toSet();

      return _selectedClasses.any(
        (selectedClass) =>
            spellClasses.contains(_normalizeClassName(selectedClass)),
      );
    }).toList();

    if (notify) {
      notifyListeners();
    }
  }

  List<String> _extractAvailableClasses(List<Map<String, dynamic>> spells) {
    final classes = <String>{};

    for (final spell in spells) {
      classes.addAll(_classesForSpell(spell));
    }

    final sortedClasses = classes
        .where((className) => className.trim().isNotEmpty)
        .map(_displayClassName)
        .toSet()
        .toList();

    sortedClasses.sort((first, second) => first.compareTo(second));

    return sortedClasses;
  }

  Set<String> _classesForSpell(Map<String, dynamic> spell) {
    final classes = <String>{};

    void addValue(dynamic value) {
      if (value == null) {
        return;
      }

      if (value is String) {
        final values = value.split(
          RegExp(r'\s*(?:,|;|/|\|)\s*|\s+and\s+', caseSensitive: false),
        );

        for (final item in values) {
          final className = item.trim();

          if (className.isNotEmpty) {
            classes.add(_displayClassName(className));
          }
        }

        return;
      }

      if (value is Iterable) {
        for (final item in value) {
          addValue(item);
        }

        return;
      }

      if (value is Map) {
        addValue(value['name'] ?? value['slug'] ?? value['key']);
      }
    }

    /*
     * dnd_class es el campo utilizado por tu endpoint actual.
     * Los demás campos permiten compatibilidad con otras versiones
     * de la respuesta de la API.
     */
    addValue(spell['dnd_class']);
    addValue(spell['dnd_classes']);
    addValue(spell['classes']);
    addValue(spell['spell_lists']);

    return classes;
  }

  int _spellLevel(Map<String, dynamic> spell) {
    final levelInt = spell['level_int'];

    if (levelInt is int) {
      return levelInt;
    }

    if (levelInt is num) {
      return levelInt.toInt();
    }

    final rawLevel = spell['level'];

    if (rawLevel is int) {
      return rawLevel;
    }

    if (rawLevel is num) {
      return rawLevel.toInt();
    }

    final levelText = rawLevel?.toString().trim().toLowerCase();

    if (levelText == null || levelText.isEmpty) {
      return -1;
    }

    if (levelText.contains('cantrip')) {
      return 0;
    }

    final match = RegExp(r'\d+').firstMatch(levelText);

    return int.tryParse(match?.group(0) ?? '') ?? -1;
  }

  String _displayClassName(String value) {
    return value
        .trim()
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
          if (word.length == 1) {
            return word.toUpperCase();
          }

          return '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  String _normalizeClassName(String value) {
    return value
        .trim()
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }
}
