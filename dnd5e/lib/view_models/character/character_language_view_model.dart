import 'package:flutter/material.dart';
import '../../utils/languajes.dart';

class CharacterLanguageViewModel extends ChangeNotifier {
  // ─── Estado ───────────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedRace;
  Map<String, dynamic>? _selectedBackground;
  Map<String, dynamic>? _selectedFeat;
  List<String> _selectedRacialLanguages = [];
  List<String> _selectedBgLanguages = [];
  List<String> _featLanguages = [];
  List<String> _featFixedLanguages = [];
  int _languagesToChooseFromFeat = 0;

  // ─── Getters: idiomas fijos ───────────────────────────────────────────────
  List<String> get selectedRacialLanguages => _selectedRacialLanguages;
  List<String> get selectedBgLanguages => _selectedBgLanguages;
  List<String> get featLanguages => _featLanguages;
  List<String> get selectedFeatLanguages => _featLanguages;
  int get languagesToChooseFromFeat => _languagesToChooseFromFeat;
  int get featLanguagesToChoose => _languagesToChooseFromFeat;

  List<String> get racialFixedLanguages {
    if (_selectedRace == null) return [];
    
    final rawLanguagesText = (_selectedRace!['languages'] ?? '').toString().toLowerCase();
    if (rawLanguagesText.isEmpty) return [];
    
    final foundLanguages = <String>[];
    for (final lang in availableLanguages) {
      if (rawLanguagesText.contains(lang.toLowerCase())) {
        foundLanguages.add(lang);
      }
    }
    return foundLanguages;
  }

  List<String> get backgroundFixedLanguages {
    if (_selectedBackground == null) return [];
    
    final raw = (_selectedBackground!['languages'] ?? '').toString().toLowerCase();
    if (raw.contains('choice') || raw.contains('no additional')) {
      return [];
    }
    
    final foundLanguages = <String>[];
    // 🟢 CORRECCIÓN: Filtramos usando la lista global 'availableLanguages' del sistema
    for (final lang in availableLanguages) {
      if (raw.contains(lang.toLowerCase())) {
        foundLanguages.add(lang);
      }
    }
    return foundLanguages;
  }

  List<String> get allKnownLanguages => {
    ...totalFixedLanguages,
    ..._selectedRacialLanguages.where((l) => l.isNotEmpty),
    ..._selectedBgLanguages.where((l) => l.isNotEmpty),
    ..._featLanguages,
  }.toList();

  List<String> get totalFixedLanguages => [
    ...racialFixedLanguages,
    ...backgroundFixedLanguages,
    ..._featFixedLanguages,
  ];
  
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

  void updateFromFeat(Map<String, dynamic>? feat) {
    _selectedFeat = feat;
    _featLanguages = [];
    _featFixedLanguages = [];
    _languagesToChooseFromFeat = 0;

    if (feat != null) {
      final effects = (feat['effects_desc'] as List? ?? []);
      final desc = feat['desc']?.toString() ?? '';

      final fullText = (desc + " " + effects.join(" ")).toLowerCase();

      // A. DETECTAR ELECCIONES LIBRES (Ej: "Linguistic")
      if (fullText.contains('three additional languages') ||
          fullText.contains('three languages')) {
        _languagesToChooseFromFeat = 3;
      } else if (fullText.contains('two additional languages') ||
          fullText.contains('two languages')) {
        _languagesToChooseFromFeat = 2;
      } else if (fullText.contains('one additional language') ||
          fullText.contains('one language')) {
        _languagesToChooseFromFeat = 1;
      }

      for (final lang in allLanguages) {
  if (fullText.contains(lang.toLowerCase()) && 
      !fullText.contains('languages of your choice')) {
    
    // CORRECCIÓN SEGURA: Validar contra la misma lista local '_featFixedLanguages'
    // en lugar de usar getters globales complicados.
    if (!_featFixedLanguages.contains(lang)) {
      _featFixedLanguages.add(lang);
    }
  }
}
    }

    notifyListeners();
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
    final raw = (_selectedBackground!['languages'] ?? '')
        .toString()
        .toLowerCase();
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

  void updateFeatLanguages(List<String> languages) {
    _featLanguages = languages;
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

  void confirmFeatLanguages(List<String> selected) {
    _featLanguages = selected;
    notifyListeners();
  }

  void reset() {
    _selectedRace = null;
    _selectedBackground = null;
    _selectedRacialLanguages = [];
    _selectedBgLanguages = [];
    _featLanguages = [];
    notifyListeners();
  }
}
