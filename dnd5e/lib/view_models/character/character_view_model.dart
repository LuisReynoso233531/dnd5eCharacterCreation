import 'package:flutter/material.dart';
import '../../data/models/character_class.dart';
import '../../data/repositories/character_repository.dart';
import 'dart:math';

class CreateCharacterViewModel extends ChangeNotifier {
  final CharacterRepository _repository;
  CreateCharacterViewModel(this._repository);

  // --- ESTADO GENERAL ---
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- DATOS (API / JSON) ---
  List<CharacterClass> _classes = [];
  List<Map<String, dynamic>> _displayRaces = [];
  List<Map<String, dynamic>> _backgrounds = [];
  List<Map<String, dynamic>> _allFeats = [];

  List<CharacterClass> get classes => _classes;
  List<String> get racialSkillProfFromTraits => racialSkillProficiencies;
  List<Map<String, dynamic>> get races => _displayRaces;
  List<Map<String, dynamic>> get backgrounds => _backgrounds;
  List<Map<String, dynamic>> get allFeats => _allFeats;

  // --- SELECCIÓN ---
  String _name = "";
  int _level = 1;
  Map<String, dynamic>? _selectedRace;
  CharacterClass? _selectedClass;
  Map<String, dynamic>? _selectedBackground;

  // Junto a _levelUpChoices:
  Map<int, ResolvedFeatChoice> _featChoices = {};
  Map<int, ResolvedFeatChoice> get featChoices => _featChoices;

  String get name => _name;
  int get level => _level;
  Map<String, dynamic>? get selectedRace => _selectedRace;
  List<String> _selectedRacialLanguages = [];
  List<String> get selectedRacialLanguages => _selectedRacialLanguages;

  CharacterClass? get selectedClass => _selectedClass;
  Map<String, dynamic>? get selectedBackground => _selectedBackground;

  // --- SKILLS ---
  final List<String> _allDndSkills = [
    'Acrobatics',
    'Animal Handling',
    'Arcana',
    'Athletics',
    'Deception',
    'History',
    'Insight',
    'Intimidation',
    'Investigation',
    'Medicine',
    'Nature',
    'Perception',
    'Performance',
    'Persuasion',
    'Religion',
    'Sleight of Hand',
    'Stealth',
    'Survival',
  ];

  List<SkillChoice> _skillChoices = [];
  List<String> _classFixedSkills = [];
  List<String> _bgFixedSkills = [];
  List<String> _selectedClassSkills = [];

  List<SkillChoice> get skillChoices => _skillChoices;
  List<String> get classFixedSkills => _classFixedSkills;
  List<String> get bgFixedSkills => _bgFixedSkills;
  List<String> get selectedClassSkills => _selectedClassSkills;
  int get totalDropdowns => _skillChoices.fold(0, (sum, c) => sum + c.count);

  List<String> get totalFixedSkills {
    final fixed = <String>[..._bgFixedSkills, ..._classFixedSkills];
    if (_selectedRace?['starting_proficiencies'] != null) {
      fixed.addAll(
        _extractSkills(_selectedRace!['starting_proficiencies'].toString()),
      );
    }
    return fixed.toSet().toList();
  }

  // --- EQUIPMENT ---
  List<String> fixedEquipment = [];
  List<String> backgroundEquipment = [];
  List<EquipmentPackage> equipmentPackages = [];
  int selectedPackageIndex = 0;

  /// Equipo total que se guardará en el personaje
  List<String> get totalEquipment {
    return [
      ...backgroundEquipment,
      ...fixedEquipment,
      if (equipmentPackages.isNotEmpty)
        ...equipmentPackages[selectedPackageIndex].items,
    ];
  }

  // --- LANGUAGES ---
  List<String> _selectedBgLanguages = [];
  int get bgLanguagesToChoose {
    if (_selectedBackground == null) return 0;
    final text = (_selectedBackground!['languages'] ?? '')
        .toString()
        .toLowerCase();
    if (text.contains('two') || text.contains('2')) return 2;
    if (text.contains('one') || text.contains('1')) return 1;
    if (text.contains('any')) return 1;
    return 0;
  }

  List<String> get selectedBgLanguages => _selectedBgLanguages;

  // ─────────────────────────────────────────
  // PROFICIENCIAS RACIALES (parseadas de traits)
  // ─────────────────────────────────────────

  /// Proficiencias de armas extraídas del campo traits de la raza
  List<String> get racialWeaponProficiencies {
    final traits = (_selectedRace?['traits'] ?? '').toString();
    return _extractWeaponProfsFromTraits(traits);
  }

  /// Proficiencias de skills extraídas del campo traits de la raza
  List<String> get racialSkillProficiencies {
    final traits = (_selectedRace?['traits'] ?? '').toString();
    return _extractSkillProfsFromTraits(traits);
  }

  /// Proficiencias de herramientas extraídas del campo traits de la raza
  List<String> get racialToolProficiencies {
    final traits = (_selectedRace?['traits'] ?? '').toString();
    return _extractToolProfsFromTraits(traits);
  }

  // --- Parsers privados ---

  List<String> _extractWeaponProfsFromTraits(String traits) {
    final weapons = <String>{};
    final lower = traits.toLowerCase();

    // Patrón: "proficiency with X, Y and Z" (armas)
    final weaponPattern = RegExp(
      r'proficiency with ([^.\n]+)',
      caseSensitive: false,
    );

    // Lista de armas conocidas para filtrar (evita mezclar con herramientas/skills)
    const knownWeapons = [
      'battleaxe',
      'handaxe',
      'light hammer',
      'warhammer',
      'longsword',
      'shortsword',
      'shortbow',
      'longbow',
      'spear',
      'crossbow',
      'dagger',
      'rapier',
      'scimitar',
      'greataxe',
      'greatsword',
      'trident',
      'javelin',
      'quarterstaff',
      'simple weapons',
      'martial weapons',
      'hand crossbow',
      'light crossbow',
      'heavy crossbow',
      'war pick',
      'flail',
      'mace',
    ];

    for (final match in weaponPattern.allMatches(lower)) {
      final found = match.group(1) ?? '';
      // Solo incluir si menciona algún arma conocida o "weapons"
      if (found.contains('weapon') ||
          knownWeapons.any((w) => found.contains(w))) {
        // Limpiar y capitalizar
        final clean = found
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'[*_]'), '')
            .trim();
        // Separar por coma y "and"
        for (var item in clean.split(RegExp(r',| and '))) {
          final t = item.trim();
          if (t.isNotEmpty && knownWeapons.any((w) => t.contains(w)) ||
              t.contains('weapon')) {
            weapons.add(_titleCase(t));
          }
        }
      }
    }
    return weapons.toList();
  }

  List<String> _extractSkillProfsFromTraits(String traits) {
    final skills = <String>{};

    // Patrón 1: "proficiency in the X skill" o "proficiency in X"
    final skillPattern1 = RegExp(
      r'proficiency in (?:the )?(\w[\w\s]+?)(?:\s*skill|\.|,|\n)',
      caseSensitive: false,
    );
    // Patrón 2: "proficiency in one of the following skills of your choice"
    final skillPattern2 = RegExp(
      r'proficiency in (?:two|one|three) skills? of your choice',
      caseSensitive: false,
    );

    for (final match in skillPattern1.allMatches(traits)) {
      final found = (match.group(1) ?? '').trim();
      // Verificar que sea un skill real de D&D
      if (_allDndSkills.any((s) => s.toLowerCase() == found.toLowerCase())) {
        skills.add(_titleCase(found));
      }
    }

    // Detectar "two skills of your choice"
    if (skillPattern2.hasMatch(traits.toLowerCase())) {
      skills.add('Two skills of your choice');
    }

    return skills.toList();
  }

  List<String> _extractToolProfsFromTraits(String traits) {
    final tools = <String>{};
    const knownTools = [
      "artisan's tools",
      "thieves' tools",
      "herbalism kit",
      "poisoner's kit",
      "disguise kit",
      "forgery kit",
      "navigator's tools",
      "alchemist's supplies",
      "brewer's supplies",
      "carpenter's tools",
      "cobbler's tools",
      "cook's utensils",
      "glassblower's tools",
      "jeweler's tools",
      "leatherworker's tools",
      "mason's tools",
      "painter's supplies",
      "potter's tools",
      "smith's tools",
      "tinker's tools",
      "weaver's tools",
      "woodcarver's tools",
      "gaming set",
      "musical instrument",
    ];

    final lower = traits.toLowerCase();
    // Patrón: "proficiency with the X" o "Tool Proficiency. You gain proficiency with..."
    final toolPattern = RegExp(
      r'proficiency with (?:the )?([^.\n]+)',
      caseSensitive: false,
    );

    for (final match in toolPattern.allMatches(lower)) {
      final found = match.group(1) ?? '';
      for (final tool in knownTools) {
        if (found.contains(tool)) {
          tools.add(_titleCase(tool));
        }
      }
    }

    return tools.toList();
  }

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  List<String> get availableLanguages => [
    "Common",
    "Dwarvish",
    "Elvish",
    "Giant",
    "Gnomish",
    "Goblin",
    "Halfling",
    "Orc",
    "Abyssal",
    "Celestial",
    "Draconic",
    "Deep Speech",
    "Infernal",
    "Primordial",
    "Sylvan",
    "Undercommon",
  ];

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

  List<String> get racialFixedLanguages {
    final raw = (_selectedRace?['languages'] ?? '').toString();
    return _allKnownLanguages
        .where((lang) => raw.toLowerCase().contains(lang.toLowerCase()))
        .toList();
  }

  bool get racialHasLanguageChoice {
    final raw = (_selectedRace?['languages'] ?? '').toString().toLowerCase();
    return raw.contains('one extra language') ||
        raw.contains('one other language') ||
        raw.contains('your choice of') ||
        raw.contains('a language associated with') ||
        raw.contains('one of the following');
  }

  List<String> get backgroundFixedLanguages {
    final raw = (_selectedBackground?['languages'] ?? '').toString();
    if (raw.toLowerCase().contains('choice') ||
        raw.toLowerCase().contains('no additional'))
      return [];
    return _allKnownLanguages
        .where((lang) => raw.toLowerCase().contains(lang.toLowerCase()))
        .toList();
  }

  List<String> get totalFixedLanguages {
    return {...racialFixedLanguages, ...backgroundFixedLanguages}.toList();
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
        raw.contains('any'))
      return 1;
    return 0;
  }

  int get racialLanguagesToChoose {
    if (!racialHasLanguageChoice) return 0;
    // "your choice of X or Y" → ya están en racialFixedLanguages como opciones
    // Solo cuenta como elección libre si dice "one extra" u "one other"
    final raw = (_selectedRace?['languages'] ?? '').toString().toLowerCase();
    if (raw.contains('one extra') ||
        raw.contains('one other') ||
        raw.contains('one of the following') ||
        raw.contains('associated with'))
      return 1;
    return 0;
  }

  void confirmRacialLanguages(List<String> selected) {
    // ← NUEVO
    _selectedRacialLanguages = selected;
    notifyListeners();
  }

  // --- STATS ---
  int _speed = 30;
  int _maxHp = 0;
  Map<String, int> baseStats = {
    'Strength': 10,
    'Dexterity': 10,
    'Constitution': 10,
    'Intelligence': 10,
    'Wisdom': 10,
    'Charisma': 10,
  };
  Map<String, int> _racialBonuses = {};
  Map<int, Map<String, dynamic>> _levelUpChoices = {};

  int get maxHp => _maxHp;
  int get speed => _speed;
  Map<String, int> get racialBonuses => _racialBonuses;
  Map<int, Map<String, dynamic>> get levelUpChoices => _levelUpChoices;

  // ─────────────────────────────────────────
  // SETTERS PRINCIPALES — aquí estaba el bug
  // ─────────────────────────────────────────

  void setBackground(Map<String, dynamic>? bg) {
    _selectedBackground = bg;
    _selectedBgLanguages = []; // ← resetear al cambiar background
    backgroundEquipment = [];
    if (bg?['equipment'] != null) {
      backgroundEquipment.add(bg!['equipment']);
    }
    _updateAllSkillLogic();
    notifyListeners();
  }

  void selectClass(CharacterClass? charClass) {
    _selectedClass = charClass;

    // Equipment de la clase
    _parseEquipmentIntoPackages();

    // Skills de la clase
    _updateAllSkillLogic();

    notifyListeners();
  }

  // ─────────────────────────────────────────
  // LÓGICA DE SKILLS
  // ─────────────────────────────────────────

  void _updateAllSkillLogic() {
    _skillChoices = [];
    _classFixedSkills = [];
    _bgFixedSkills = [];
    _selectedClassSkills = [];

    if (_selectedBackground != null) {
      _processSkillText(
        _selectedBackground!['skill_proficiencies'] ?? '',
        isBackground: true,
      );
    }
    if (_selectedClass != null) {
      _processSkillText(_selectedClass!.prof_skills ?? '', isBackground: false);
    }
  }

  void _processSkillText(String text, {required bool isBackground}) {
    final lower = text.toLowerCase();

    if (lower.contains('either')) {
      final parts = lower.split('either');
      final fixed = _extractSkills(parts[0]);
      if (isBackground) {
        _bgFixedSkills.addAll(fixed);
      } else {
        _classFixedSkills.addAll(fixed);
      }
      _skillChoices.add(
        SkillChoice(options: _extractSkills(parts[1]), count: 1),
      );
    } else if (lower.contains('choose')) {
      final count = _extractNumber(text);
      final options = lower.contains('any')
          ? List<String>.from(_allDndSkills)
          : _extractSkills(text);
      _skillChoices.add(SkillChoice(options: options, count: count));
    } else {
      final fixed = _extractSkills(text);
      if (isBackground) {
        _bgFixedSkills.addAll(fixed);
      } else {
        _classFixedSkills.addAll(fixed);
      }
    }
  }

  void confirmClassSkills(List<String> selected) {
    _selectedClassSkills = selected;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // LÓGICA DE EQUIPMENT
  // ─────────────────────────────────────────

  void _parseEquipmentIntoPackages() {
    fixedEquipment = [];
    equipmentPackages = [];
    selectedPackageIndex = 0;

    if (_selectedClass?.equipment == null) return;

    final groups = <String, List<String>>{'a': [], 'b': [], 'c': []};
    final lines = _selectedClass!.equipment!.split('\n');

    for (var line in lines) {
      final clean = line.replaceAll('*', '').trim();
      if (clean.isEmpty || clean.toLowerCase().contains('you start with')) {
        continue;
      }

      if (clean.contains('(a)')) {
        groups['a']!.add(_extractBetween(clean, '(a)', '(b)'));
        groups['b']!.add(_extractBetween(clean, '(b)', '(c)'));
        if (clean.contains('(c)')) {
          groups['c']!.add(_extractAfter(clean, '(c)'));
        }
      } else {
        fixedEquipment.add(clean);
      }
    }

    equipmentPackages = groups.entries
        .where((e) => e.value.isNotEmpty)
        .map(
          (e) => EquipmentPackage(letter: e.key.toUpperCase(), items: e.value),
        )
        .toList();
  }

  List<String> get fixedLanguages {
    final langs = <String>[];
    if (_selectedRace?['languages'] != null) {
      langs.addAll(
        _selectedRace!['languages']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }
    return langs;
  }

  void setPackageIndex(int index) {
    selectedPackageIndex = index;
    notifyListeners();
  }

  String _extractBetween(String text, String start, String end) {
    final si = text.indexOf(start);
    if (si == -1) return '';
    final ei = text.indexOf(end, si + start.length);
    return _cleanText(
      text.substring(si + start.length, ei == -1 ? text.length : ei),
    );
  }

  String _extractAfter(String text, String start) {
    final si = text.indexOf(start);
    if (si == -1) return '';
    return _cleanText(text.substring(si + start.length));
  }

  String _cleanText(String t) =>
      t.replaceAll(RegExp(r'\s+or\s*$|\s+and\s*$|\.$'), '').trim();

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  List<String> _extractSkills(String text) => _allDndSkills
      .where((s) => text.toLowerCase().contains(s.toLowerCase()))
      .toList();

  int _extractNumber(String text) {
    if (text.contains('3') || text.toLowerCase().contains('three')) return 3;
    if (text.contains('2') || text.toLowerCase().contains('two')) return 2;
    return 1;
  }

  // ─────────────────────────────────────────
  // STATS & LEVEL
  // ─────────────────────────────────────────

  void setRace(Map<String, dynamic> raceData) {
    _selectedRace = raceData;
    _selectedRacialLanguages = [];
    _racialBonuses.clear();
    for (var bonus in (raceData['asi'] as List<dynamic>? ?? [])) {
      final attr = bonus['attributes'][0].toString();
      _racialBonuses[attr] =
          (_racialBonuses[attr] ?? 0) + (bonus['value'] as int);
    }
    _speed = (raceData['speed'] is Map)
        ? (raceData['speed']['walk'] ?? 30)
        : 30;
    _calculateMaxHp();
    notifyListeners();
  }

  void updateBaseStat(String stat, int newValue) {
    if (newValue >= 0 && newValue <= 30) {
      baseStats[stat] = newValue;
      _calculateMaxHp();
      notifyListeners();
    }
  }

  void rollRandomStats() {
    final random = Random();
    final names = [
      'Strength',
      'Dexterity',
      'Constitution',
      'Intelligence',
      'Wisdom',
      'Charisma',
    ];
    baseStats = {
      for (var s in names)
        s: () {
          final rolls = List.generate(4, (_) => random.nextInt(6) + 1)..sort();
          return rolls[1] + rolls[2] + rolls[3];
        }(),
    };
    _calculateMaxHp();
    notifyListeners();
  }

  int getTotalStat(String statName) {
    int total = (baseStats[statName] ?? 10) + (_racialBonuses[statName] ?? 0);

    _levelUpChoices.forEach((lvl, choice) {
      if (lvl <= _level) {
        if (choice['type'] == 'points') {
          total += (Map<String, int>.from(choice['data'])[statName] ?? 0);
        }
        if (choice['type'] == 'feat') {
          // Primero: ¿el usuario eligió un stat específico para este feat?
          final resolved = _featChoices[lvl];
          if (resolved?.chosenStat == statName) {
            total += 1;
            return; // ya sumamos, no procesar más
          }

          // Segundo: stat fijo (sin elección) — solo si NO es "or" pattern
          if (resolved == null) {
            final effects = (choice['data']['effects_desc'] as List? ?? []);
            for (var e in effects) {
              final desc = e.toString().toLowerCase();
              final s = statName.toLowerCase();
              // Solo match si NO contiene "or" (esos requieren elección)
              if (!desc.contains(' or ') &&
                  RegExp(
                    'increase your $s (score )?by 1|$s (score )?increases by 1|raise your $s .* by 1',
                    caseSensitive: false,
                  ).hasMatch(desc)) {
                total += 1;
              }
            }
          }
        }
      }
    });
    return total;
  }

  int getModifier(String statName) =>
      ((getTotalStat(statName) - 10) / 2).floor();

  void updateLevel(int newLevel) {
    _level = newLevel;
    _calculateMaxHp();
    notifyListeners();
  }

  void setLevelChoice(
    int level,
    String type,
    dynamic data, {
    ResolvedFeatChoice? featChoice,
  }) {
    _levelUpChoices[level] = {'type': type, 'data': data};
    if (featChoice != null) {
      _featChoices[level] = featChoice;
    } else {
      _featChoices.remove(level);
    }
    _calculateMaxHp();
    notifyListeners();
  }

  List<String> get allToolAndArmorProficiencies {
    final result = <String>{};

    // De la clase
    if (_selectedClass?.prof_tools != null ||
        _selectedClass?.prof_armor != null ||
        _selectedClass?.prof_weapons != null) {
      result.addAll(_parseList(_selectedClass!.prof_tools!));
    }

    // De feats seleccionados
    _levelUpChoices.forEach((lvl, choice) {
      if (choice['type'] == 'feat') {
        final effects = (choice['data']['effects_desc'] as List? ?? []);
        for (var e in effects) {
          final text = e.toString().toLowerCase();
          if (text.contains('proficiency') || text.contains('proficient')) {
            // Extraemos la línea limpia como etiqueta
            result.add(_cleanProficiencyText(e.toString()));
          }
        }
      }
    });

    return result.where((s) => s.isNotEmpty).toList();
  }

  List<String> _parseList(dynamic data) {
    if (data == null || data.toString().isEmpty || data == "null") return [];
    return data.toString().split(',').map((e) => e.trim()).toList();
  }

  String _cleanProficiencyText(String text) {
    // Recorta a max 80 chars para mostrar en chip
    final clean = text.replaceAll(RegExp(r'\*'), '').trim();
    return clean.length > 80 ? '${clean.substring(0, 77)}…' : clean;
  }

  bool doesLevelGiveImprovement(int l) => [4, 8, 12, 16, 19].contains(l);

  List<int> get availableImprovementLevels =>
      [4, 8, 12, 16, 19].where((l) => _level >= l).toList();

  bool get isLevelUpComplete => availableImprovementLevels.every(
    (lvl) => _levelUpChoices.containsKey(lvl),
  );

  bool canTakeFeat(Map<String, dynamic> feat) {
    final req = (feat['prerequisite'] ?? '').toString().toLowerCase();
    if (req.isEmpty || req == 'null' || req == 'none') return true;
    for (var stat in [
      'strength',
      'dexterity',
      'constitution',
      'intelligence',
      'wisdom',
      'charisma',
    ]) {
      if (req.contains(stat)) {
        final minVal = int.tryParse(req.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return getTotalStat(stat[0].toUpperCase() + stat.substring(1)) >=
            minVal;
      }
    }
    if (req.contains('level')) {
      return _level >=
          (int.tryParse(req.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
    }
    return true;
  }

  void _calculateMaxHp() {
    if (_selectedClass == null) return;
    final die = int.tryParse(_selectedClass!.hit_dice) ?? 8;
    final con = getModifier('Constitution');
    _maxHp =
        die +
        con +
        (_level > 1 ? ((die / 2).floor() + 1 + con) * (_level - 1) : 0);
  }

  // ─────────────────────────────────────────
  // FETCH & RESET
  // ─────────────────────────────────────────

  Future<void> loadFeatsIfNeeded() async {
    if (_allFeats.isNotEmpty) return;
    _setLoading(true);
    try {
      _allFeats = List<Map<String, dynamic>>.from(await _repository.getFeats());
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar Feats: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRaces() async =>
      _fetch(() => _repository.getRaces(), (data) {
        _displayRaces = [
          for (var r in data)
            ...() {
              final subs = r['subraces'] as List<dynamic>?;
              if (subs == null || subs.isEmpty) return [r];
              return [
                for (var sub in subs)
                  {
                    'name': "${r['name']} (${sub['name']})",
                    'asi': [...(r['asi'] ?? []), ...(sub['asi'] ?? [])],
                    'speed': sub['speed'] ?? r['speed'],
                    'traits': "${r['traits'] ?? ''}\n\n${sub['traits'] ?? ''}",
                    'languages': sub['languages'] ?? r['languages'],
                  },
              ];
            }(),
        ];
      });

  Future<void> fetchBackgrounds() async =>
      _fetch(() => _repository.getBackgrounds(), (data) => _backgrounds = data);
  Future<void> fetchAvailableClasses() async =>
      _fetch(() => _repository.getClasses(), (data) => _classes = data);
  Future<void> fetchFeats() async => loadFeatsIfNeeded();

  Future<void> _fetch(
    Future<dynamic> Function() call,
    Function(dynamic) onSuccess,
  ) async {
    _setLoading(true);
    try {
      onSuccess(await call());
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void resetCreation() {
    _name = '';
    _level = 1;
    _selectedRace = _selectedClass = _selectedBackground = null;
    _racialBonuses.clear();
    _levelUpChoices.clear();
    _selectedClassSkills.clear();
    _selectedBgLanguages.clear();
    fixedEquipment.clear();
    backgroundEquipment.clear();
    _featChoices.clear();
    _selectedRacialLanguages.clear();
    equipmentPackages.clear();
    notifyListeners();
  }

  List<String> get armorProficiencies {
    final profs = <String>{};
    if (_selectedClass?.prof_armor != null &&
        _selectedClass!.prof_armor!.isNotEmpty &&
        _selectedClass!.prof_armor != 'null') {
      profs.add(_selectedClass!.prof_armor!);
    }
    return profs.toList();
  }

  List<String> get weaponProficiencies {
    final profs = <String>{};
    // De la clase
    if (_selectedClass?.prof_weapons != null &&
        _selectedClass!.prof_weapons!.isNotEmpty &&
        _selectedClass!.prof_weapons != 'null') {
      profs.add(_selectedClass!.prof_weapons!);
    }
    // De la raza (parseadas de traits)
    profs.addAll(racialWeaponProficiencies);
    return profs.toList();
  }

  List<String> get toolProficiencies {
    final profs = <String>{};
    // De la clase
    if (_selectedClass?.prof_tools != null &&
        _selectedClass!.prof_tools!.isNotEmpty &&
        _selectedClass!.prof_tools != 'null') {
      profs.add(_selectedClass!.prof_tools!);
    }
    // Del background
    final bgTools = _selectedBackground?['tool_proficiencies'];
    if (bgTools != null &&
        bgTools.toString().isNotEmpty &&
        bgTools.toString() != 'null') {
      profs.add(bgTools.toString());
    }
    // De la raza (parseadas de traits)
    profs.addAll(racialToolProficiencies);
    return profs.toList();
  }

  // --- Lógica de Idiomas Consolidada ---

  void confirmBgLanguages(List<String> selected) {
    _selectedBgLanguages = selected;
    notifyListeners();
  }
}

// ─── Modelos de datos ───
class SkillChoice {
  final List<String> options;
  final int count;
  SkillChoice({required this.options, this.count = 1});
}

class EquipmentPackage {
  final String letter;
  final List<String> items;
  EquipmentPackage({required this.letter, required this.items});
}

class ResolvedFeatChoice {
  final String? chosenStat;
  final List<String> proficiencies;
  ResolvedFeatChoice({this.chosenStat, this.proficiencies = const []});
}
