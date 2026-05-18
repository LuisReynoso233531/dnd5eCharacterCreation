import 'package:flutter/material.dart';

class CharacterLanguageViewModel extends ChangeNotifier {
  // ─── Constantes ───────────────────────────────────────────────────────────
  static const List<String> _allLanguages = [
    'Common',
    'Dwarvish',
    'Elvish',
    'Giant',
    'Gnomish',
    'Goblin',
    'Halfling',
    'Orc',
    'Abyssal',
    'Celestial',
    'Draconic',
    'Deep Speech',
    'Infernal',
    'Primordial',
    'Sylvan',
    'Undercommon',
  ];
  List<String> get availableLanguages => _allLanguages;
  static const List<String> _allKnownLanguages = [
    'Common',
    'Dwarvish',
    'Elvish',
    'Giant',
    'Gnomish',
    'Goblin',
    'Halfling',
    'Orc',
    'Abyssal',
    'Celestial',
    'Draconic',
    'Deep Speech',
    'Infernal',
    'Primordial',
    'Sylvan',
    'Undercommon',
    'Darakhul',
    'Erina',
    'Minotaur',
    'Mushroomfolk',
    'Machine Speech',
    'Void Speech',
  ];

  // ─── Estado ───────────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRace;
  Map<String, dynamic>? _selectedBackground;
  List<String> _selectedRacialLanguages = [];
  List<String> _selectedBgLanguages = [];

  // ─── Getters: idiomas fijos ───────────────────────────────────────────────
  List<String> get selectedRacialLanguages => _selectedRacialLanguages;
  List<String> get selectedBgLanguages => _selectedBgLanguages;

  List<String> get racialFixedLanguages {
    final raw = (_selectedRace?['languages'] ?? '').toString();
    return _allKnownLanguages
        .where((lang) => raw.toLowerCase().contains(lang.toLowerCase()))
        .toList();
  }

  List<String> get backgroundFixedLanguages {
    final raw = (_selectedBackground?['languages'] ?? '').toString();
    if (raw.toLowerCase().contains('choice') ||
        raw.toLowerCase().contains('no additional')) {
      return [];
    }
    return _allKnownLanguages
        .where((lang) => raw.toLowerCase().contains(lang.toLowerCase()))
        .toList();
  }

  List<String> get totalFixedLanguages =>
      {...racialFixedLanguages, ...backgroundFixedLanguages}.toList();

  // ─── Getters: cantidad a elegir ───────────────────────────────────────────
  bool get racialHasLanguageChoice {
    final raw = (_selectedRace?['languages'] ?? '').toString().toLowerCase();
    return raw.contains('one extra language') ||
        raw.contains('one other language') ||
        raw.contains('your choice of') ||
        raw.contains('a language associated with') ||
        raw.contains('one of the following');
  }

  bool _checkTextForChoice(String text) {
    final cleanText = text.toLowerCase();
    return cleanText.contains('one extra language') ||
           cleanText.contains('one other language') ||
           cleanText.contains('extra language') || // Específicamente para High Elf
           cleanText.contains('your choice of') ||
           cleanText.contains('a language associated with') ||
           cleanText.contains('any one language') ||
           cleanText.contains('one of the following');
  }



int get racialLanguagesToChoose {
    if (_selectedRace == null) return 0;

    // 1. Buscamos en el campo 'languages'
    final languagesText = (_selectedRace?['languages'] ?? '').toString();
    // 2. Buscamos en el campo 'traits' (Aquí es donde High Elf tiene la info)
    final traitsText = (_selectedRace?['traits'] ?? '').toString();

    // Si CUALQUIERA de los dos campos tiene la instrucción, devolvemos 1
    if (_checkTextForChoice(languagesText) || _checkTextForChoice(traitsText)) {
      return 1;
    }

    return 0;
  }

  int get languagesToChooseFromBackground {
    if (_selectedBackground == null) return 0;
    final raw =
        (_selectedBackground!['languages'] ?? '').toString().toLowerCase();
    if (raw.contains('no additional') || raw.isEmpty || raw == 'null') return 0;
    if (raw.contains('two') || raw.contains('2')) return 2;
    if (raw.contains('three') || raw.contains('3')) return 3;
    if (raw.contains('one') ||
        raw.contains('1') ||
        raw.contains('choice') ||
        raw.contains('any')) {
      return 1;
    }
    return 0;
  }

  int get bgLanguagesToChoose => languagesToChooseFromBackground;

  // ─── Métodos públicos ─────────────────────────────────────────────────────
  void updateFromRace(Map<String, dynamic>? race) {
    _selectedRace = race;
    _selectedRacialLanguages = [];
    notifyListeners();
  }

  void updateFromBackground(Map<String, dynamic>? background) {
    _selectedBackground = background;
    _selectedBgLanguages = [];
    notifyListeners();
  }

  void confirmRacialLanguages(List<String> selected) {
    _selectedRacialLanguages = selected;
    notifyListeners();
  }

  void confirmBgLanguages(List<String> selected) {
    _selectedBgLanguages = selected;
    notifyListeners();
  }

  void reset() {
    _selectedRace = null;
    _selectedBackground = null;
    _selectedRacialLanguages = [];
    _selectedBgLanguages = [];
    notifyListeners();
  }
}