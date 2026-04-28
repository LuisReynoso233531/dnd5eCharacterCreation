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
  List<Map<String, dynamic>> get races => _displayRaces;
  List<Map<String, dynamic>> get backgrounds => _backgrounds;
  List<Map<String, dynamic>> get allFeats => _allFeats;

  // --- SELECCIÓN ---
  String _name = "";
  int _level = 1;
  Map<String, dynamic>? _selectedRace;
  CharacterClass? _selectedClass;
  Map<String, dynamic>? _selectedBackground;

  String get name => _name;
  int get level => _level;
  Map<String, dynamic>? get selectedRace => _selectedRace;
  CharacterClass? get selectedClass => _selectedClass;
  Map<String, dynamic>? get selectedBackground => _selectedBackground;

  // --- SKILLS ---
  final List<String> _allDndSkills = [
    'Acrobatics', 'Animal Handling', 'Arcana', 'Athletics', 'Deception',
    'History', 'Insight', 'Intimidation', 'Investigation', 'Medicine',
    'Nature', 'Perception', 'Performance', 'Persuasion', 'Religion',
    'Sleight of Hand', 'Stealth', 'Survival',
  ];

  List<SkillChoice> _skillChoices = [];
  List<String> _classFixedSkills = [];
  List<String> _bgFixedSkills = [];
  List<String> _selectedClassSkills = [];

  List<SkillChoice> get skillChoices => _skillChoices;
  List<String> get classFixedSkills => _classFixedSkills;
  List<String> get bgFixedSkills => _bgFixedSkills;
  List<String> get selectedClassSkills => _selectedClassSkills;
  int get totalDropdowns =>
      _skillChoices.fold(0, (sum, c) => sum + c.count);

  List<String> get totalFixedSkills {
    final fixed = <String>[..._bgFixedSkills, ..._classFixedSkills];
    if (_selectedRace?['starting_proficiencies'] != null) {
      fixed.addAll(
          _extractSkills(_selectedRace!['starting_proficiencies'].toString()));
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
  int _bgLanguagesToChoose = 0;
  List<String> _selectedBgLanguages = [];
  int get bgLanguagesToChoose => _bgLanguagesToChoose;
  List<String> get selectedBgLanguages => _selectedBgLanguages;

  List<String> get availableLanguages => [
        "Common", "Dwarvish", "Elvish", "Giant", "Gnomish", "Goblin",
        "Halfling", "Orc", "Abyssal", "Celestial", "Draconic",
        "Deep Speech", "Infernal", "Primordial", "Sylvan", "Undercommon",
      ];

  // --- STATS ---
  int _speed = 30;
  int _maxHp = 0;
  Map<String, int> baseStats = {
    'Strength': 10, 'Dexterity': 10, 'Constitution': 10,
    'Intelligence': 10, 'Wisdom': 10, 'Charisma': 10,
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

    // Equipment del background
    backgroundEquipment = [];
    if (bg?['equipment'] != null) {
      backgroundEquipment.add(bg!['equipment']);
    }

    // Skills del background
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
      _processSkillText(
        _selectedClass!.prof_skills ?? '',
        isBackground: false,
      );
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
      _skillChoices.add(SkillChoice(options: _extractSkills(parts[1]), count: 1));
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

  void confirmBgLanguages(List<String> selected) {
    _selectedBgLanguages = selected;
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
        .map((e) => EquipmentPackage(letter: e.key.toUpperCase(), items: e.value))
        .toList();
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
        text.substring(si + start.length, ei == -1 ? text.length : ei));
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

  List<String> _extractSkills(String text) =>
      _allDndSkills
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
    _racialBonuses.clear();
    for (var bonus in (raceData['asi'] as List<dynamic>? ?? [])) {
      final attr = bonus['attributes'][0].toString();
      _racialBonuses[attr] = (_racialBonuses[attr] ?? 0) + (bonus['value'] as int);
    }
    _speed = (raceData['speed'] is Map) ? (raceData['speed']['walk'] ?? 30) : 30;
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
    final names = ['Strength', 'Dexterity', 'Constitution',
                   'Intelligence', 'Wisdom', 'Charisma'];
    baseStats = {
      for (var s in names)
        s: () {
          final rolls = List.generate(4, (_) => random.nextInt(6) + 1)..sort();
          return rolls[1] + rolls[2] + rolls[3];
        }()
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
          final desc = (choice['data']['desc'] ?? '').toString().toLowerCase();
          final s = statName.toLowerCase();
          if (RegExp('increase your $s (score )?by 1|$s increases by 1',
                  caseSensitive: false)
              .hasMatch(desc)) total += 1;
        }
      }
    });
    return total;
  }

  int getModifier(String statName) => ((getTotalStat(statName) - 10) / 2).floor();

  void updateLevel(int newLevel) {
    _level = newLevel;
    _calculateMaxHp();
    notifyListeners();
  }

  void setLevelChoice(int level, String type, dynamic data) {
    _levelUpChoices[level] = {'type': type, 'data': data};
    _calculateMaxHp();
    notifyListeners();
  }

  bool doesLevelGiveImprovement(int l) => [4, 8, 12, 16, 19].contains(l);

  List<int> get availableImprovementLevels =>
      [4, 8, 12, 16, 19].where((l) => _level >= l).toList();

  bool get isLevelUpComplete => availableImprovementLevels
      .every((lvl) => _levelUpChoices.containsKey(lvl));

  bool canTakeFeat(Map<String, dynamic> feat) {
    final req = (feat['prerequisite'] ?? '').toString().toLowerCase();
    if (req.isEmpty || req == 'null' || req == 'none') return true;
    for (var stat in ['strength','dexterity','constitution','intelligence','wisdom','charisma']) {
      if (req.contains(stat)) {
        final minVal = int.tryParse(req.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return getTotalStat(stat[0].toUpperCase() + stat.substring(1)) >= minVal;
      }
    }
    if (req.contains('level')) {
      return _level >= (int.tryParse(req.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
    }
    return true;
  }

  void _calculateMaxHp() {
    if (_selectedClass == null) return;
    final die = int.tryParse(_selectedClass!.hit_dice) ?? 8;
    final con = getModifier('Constitution');
    _maxHp = die + con + (_level > 1 ? ((die / 2).floor() + 1 + con) * (_level - 1) : 0);
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

  Future<void> fetchRaces() async => _fetch(() => _repository.getRaces(), (data) {
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
                  }
              ];
            }()
        ];
      });

  Future<void> fetchBackgrounds() async =>
      _fetch(() => _repository.getBackgrounds(), (data) => _backgrounds = data);
  Future<void> fetchAvailableClasses() async =>
      _fetch(() => _repository.getClasses(), (data) => _classes = data);
  Future<void> fetchFeats() async => loadFeatsIfNeeded();

  Future<void> _fetch(Future<dynamic> Function() call, Function(dynamic) onSuccess) async {
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
    equipmentPackages.clear();
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