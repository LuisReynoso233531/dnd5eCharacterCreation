import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/models/character_class.dart';
import '../../data/repositories/character_repository.dart';
import 'character_skill_view_model.dart';
import 'character_equipment_view_model.dart';
import 'character_language_view_model.dart';

class CreateCharacterViewModel extends ChangeNotifier {
  // ─── Dependencias ─────────────────────────────────────────────────────────
  final CharacterRepository _repository;
  final CharacterSkillViewModel skillVM;
  final CharacterEquipmentViewModel equipmentVM;
  final CharacterLanguageViewModel languageVM;

  CreateCharacterViewModel(
    this._repository, {
    CharacterSkillViewModel? skillViewModel,
    CharacterEquipmentViewModel? equipmentViewModel,
    CharacterLanguageViewModel? languageViewModel,
  }) : skillVM = skillViewModel ?? CharacterSkillViewModel(),
       equipmentVM = equipmentViewModel ?? CharacterEquipmentViewModel(),
       languageVM = languageViewModel ?? CharacterLanguageViewModel();

  // ─── Estado general ───────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Datos (API) ──────────────────────────────────────────────────────────
  List<CharacterClass> _classes = [];
  List<Map<String, dynamic>> _displayRaces = [];
  List<Map<String, dynamic>> _backgrounds = [];
  List<Map<String, dynamic>> _allFeats = [];

  List<CharacterClass> get classes => _classes;
  List<Map<String, dynamic>> get races => _displayRaces;
  List<Map<String, dynamic>> get backgrounds => _backgrounds;
  List<Map<String, dynamic>> get allFeats => _allFeats;

  // ─── Selección ────────────────────────────────────────────────────────────
  String _name = '';
  int _level = 1;
  Map<String, dynamic>? _selectedRace;
  CharacterClass? _selectedClass;
  Map<String, dynamic>? _selectedBackground;

  String get name => _name;
  int get level => _level;
  Map<String, dynamic>? get selectedRace => _selectedRace;
  CharacterClass? get selectedClass => _selectedClass;
  Map<String, dynamic>? get selectedBackground => _selectedBackground;

  // ─── Stats ────────────────────────────────────────────────────────────────
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
  Map<int, ResolvedFeatChoice> _featChoices = {};

  int get maxHp => _maxHp;
  int get speed => _speed;
  Map<String, int> get racialBonuses => _racialBonuses;
  Map<int, Map<String, dynamic>> get levelUpChoices => _levelUpChoices;
  Map<int, ResolvedFeatChoice> get featChoices => _featChoices;
  Map<String, String>? _selectedDraconicAncestry;
  Map<String, String>? get selectedDraconicAncestry =>
      _selectedDraconicAncestry;

  // ─── Proficiencias raciales (delegadas al parser de traits) ───────────────
  List<String> get racialWeaponProficiencies => _extractWeaponProfsFromTraits(
    (_selectedRace?['traits'] ?? '').toString(),
  );

  List<String> get racialSkillProficiencies =>
      _extractSkillProfsFromTraits((_selectedRace?['traits'] ?? '').toString());

  // alias para compatibilidad con views existentes
  List<String> get racialSkillProfFromTraits => racialSkillProficiencies;

  List<String> get racialToolProficiencies =>
      _extractToolProfsFromTraits((_selectedRace?['traits'] ?? '').toString());

  // ─── Proficiencias consolidadas ───────────────────────────────────────────
  List<String> get armorProficiencies {
    final prof = _selectedClass?.prof_armor ?? '';
    if (prof.isEmpty || prof == 'null') return [];
    return [prof];
  }

  List<String> get weaponProficiencies => {
    if (_selectedClass?.prof_weapons?.isNotEmpty == true &&
        _selectedClass!.prof_weapons != 'null')
      _selectedClass!.prof_weapons!,
    ...racialWeaponProficiencies,
  }.toList();

  List<String> get toolProficiencies {
    final profs = <String>{};
    if (_selectedClass?.prof_tools?.isNotEmpty == true &&
        _selectedClass!.prof_tools != 'null') {
      profs.add(_selectedClass!.prof_tools!);
    }
    final bgTools = _selectedBackground?['tool_proficiencies']?.toString();
    if (bgTools != null && bgTools.isNotEmpty && bgTools != 'null') {
      profs.add(bgTools);
    }
    profs.addAll(racialToolProficiencies);
    return profs.toList();
  }

  List<String> get allToolAndArmorProficiencies {
    final result = <String>{};
    if (_selectedClass?.prof_tools != null) {
      result.addAll(_parseList(_selectedClass!.prof_tools));
    }
    _levelUpChoices.forEach((_, choice) {
      if (choice['type'] == 'feat') {
        for (var e in (choice['data']['effects_desc'] as List? ?? [])) {
          final text = e.toString().toLowerCase();
          if (text.contains('proficiency') || text.contains('proficient')) {
            result.add(_cleanProficiencyText(e.toString()));
          }
        }
      }
    });
    return result.where((s) => s.isNotEmpty).toList();
  }

  static const List<Map<String, String>> draconicAncestries = [
    {
      'dragon': 'Black',
      'damage_type': 'Acid',
      'breath_weapon': '5 by 30 ft. line (Dex. save)',
    },
    {
      'dragon': 'Blue',
      'damage_type': 'Lightning',
      'breath_weapon': '5 by 30 ft. line (Dex. save)',
    },
    {
      'dragon': 'Brass',
      'damage_type': 'Fire',
      'breath_weapon': '5 by 30 ft. line (Dex. save)',
    },
    {
      'dragon': 'Bronze',
      'damage_type': 'Lightning',
      'breath_weapon': '5 by 30 ft. line (Dex. save)',
    },
    {
      'dragon': 'Copper',
      'damage_type': 'Acid',
      'breath_weapon': '5 by 30 ft. line (Dex. save)',
    },
    {
      'dragon': 'Gold',
      'damage_type': 'Fire',
      'breath_weapon': '15 ft. cone (Dex. save)',
    },
    {
      'dragon': 'Green',
      'damage_type': 'Poison',
      'breath_weapon': '15 ft. cone (Con. save)',
    },
    {
      'dragon': 'Red',
      'damage_type': 'Fire',
      'breath_weapon': '15 ft. cone (Dex. save)',
    },
    {
      'dragon': 'Silver',
      'damage_type': 'Cold',
      'breath_weapon': '15 ft. cone (Con. save)',
    },
    {
      'dragon': 'White',
      'damage_type': 'Cold',
      'breath_weapon': '15 ft. cone (Con. save)',
    },
  ];

  void setDraconicAncestry(Map<String, String>? ancestry) {
    _selectedDraconicAncestry = ancestry;
    notifyListeners();
  }

  // Getter para obtener el texto formateado que guardarás en los traits más adelante
  String get dragonbornTraitsSummary {
    if (_selectedDraconicAncestry == null) return "";
    final d = _selectedDraconicAncestry!;
    return "Draconic Ancestry: ${d['dragon']}\n"
        "Damage Resistance: ${d['damage_type']}\n"
        "Breath Weapon: ${d['damage_type']} damage, ${d['breath_weapon']}";
  }

 String getCleanedRaceTraits() {
    final race = selectedRace; // Usamos la variable directa de la clase
    if (race == null) return '';

    String traits = race['traits']?.toString() ?? '';

    if (race['slug'] == 'dragonborn') {
      final selected = selectedDraconicAncestry;

      // 1. Eliminar la tabla Markdown completa (método seguro por líneas)
      final lines = traits.split('\n');
      final cleanLines = lines.where((line) => !line.trim().startsWith('|')).toList();
      traits = cleanLines.join('\n');

      // 2. Eliminar el título "Draconic Ancestry" suelto que queda arriba
      traits = traits.replaceAll('**Draconic Ancestry**', '').trim();

      // 3. Limpiar saltos de línea gigantes
      traits = traits.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

      // Si no eligió ancestría aún, mostramos solo el texto limpio sin la tabla
      if (selected == null) return traits;

      // 4. Si eligió, anteponer su elección específica como bloque destacado
      final ancestryBlock = 'DRACONIC ANCESTRY: ${selected['dragon']?.toUpperCase()}\n'
          '• Damage Resistance: ${selected['damage_type']}\n'
          '• Breath Weapon: ${selected['breath_weapon']}';

      return '$ancestryBlock\n\n$traits';
    }

    return traits;
  }

  // ─── Setters principales ──────────────────────────────────────────────────
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setRace(Map<String, dynamic> raceData) {
    _selectedRace = raceData;
    _racialBonuses.clear();
    for (final bonus in (raceData['asi'] as List<dynamic>? ?? [])) {
      final attr = bonus['attributes'][0].toString();
      _racialBonuses[attr] =
          (_racialBonuses[attr] ?? 0) + (bonus['value'] as int);
    }
    _speed = (raceData['speed'] is Map)
        ? (raceData['speed']['walk'] ?? 30)
        : 30;

    languageVM.updateFromRace(raceData);
    _calculateMaxHp();
    notifyListeners();
  }

  void selectClass(CharacterClass? charClass) {
    _selectedClass = charClass;
    equipmentVM.updateFromClass(charClass);
    skillVM.updateFromSelections(
      background: _selectedBackground,
      charClass: charClass,
    );
    notifyListeners();
  }

  void setBackground(Map<String, dynamic>? bg) {
    _selectedBackground = bg;
    equipmentVM.updateFromBackground(bg);
    languageVM.updateFromBackground(bg);
    skillVM.updateFromSelections(background: bg, charClass: _selectedClass);
    notifyListeners();
  }

  // ─── Stats y nivel ────────────────────────────────────────────────────────
  void updateBaseStat(String stat, int newValue) {
    if (newValue < 0 || newValue > 30) return;
    baseStats[stat] = newValue;
    _calculateMaxHp();
    notifyListeners();
  }

  void rollRandomStats() {
    final random = Random();
    const statNames = [
      'Strength',
      'Dexterity',
      'Constitution',
      'Intelligence',
      'Wisdom',
      'Charisma',
    ];
    baseStats = {
      for (final s in statNames)
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
      if (lvl > _level) return;
      if (choice['type'] == 'points') {
        total += (Map<String, int>.from(choice['data'])[statName] ?? 0);
      }
      if (choice['type'] == 'feat') {
        final resolved = _featChoices[lvl];
        if (resolved?.chosenStat == statName) {
          total += 1;
          return;
        }
        if (resolved == null) {
          for (var e in (choice['data']['effects_desc'] as List? ?? [])) {
            final desc = e.toString().toLowerCase();
            final s = statName.toLowerCase();
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

  // ─── Feats ────────────────────────────────────────────────────────────────
  bool doesLevelGiveImprovement(int l) => [4, 8, 12, 16, 19].contains(l);

  List<int> get availableImprovementLevels =>
      [4, 8, 12, 16, 19].where((l) => _level >= l).toList();

  bool get isLevelUpComplete => availableImprovementLevels.every(
    (lvl) => _levelUpChoices.containsKey(lvl),
  );

  bool canTakeFeat(Map<String, dynamic> feat) {
    final req = (feat['prerequisite'] ?? '').toString().toLowerCase();
    if (req.isEmpty || req == 'null' || req == 'none') return true;
    for (final stat in [
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

  // ─── Fetch ────────────────────────────────────────────────────────────────
  Future<void> fetchAvailableClasses() async =>
      _fetch(() => _repository.getClasses(), (data) => _classes = data);

  Future<void> fetchRaces() async =>
      _fetch(() => _repository.getRaces(), (data) {
        _displayRaces = [
          for (final r in data)
            ...() {
              final subs = r['subraces'] as List<dynamic>?;
              if (subs == null || subs.isEmpty) return [r];
              return [
                for (final sub in subs)
                  {
                    'name': '${r['name']} (${sub['name']})',
                    'asi': [...(r['asi'] ?? []), ...(sub['asi'] ?? [])],
                    'speed': sub['speed'] ?? r['speed'],
                    'traits': '${r['traits'] ?? ''}\n\n${sub['traits'] ?? ''}',
                    'languages': sub['languages'] ?? r['languages'],
                  },
              ];
            }(),
        ];
      });

  Future<void> fetchBackgrounds() async =>
      _fetch(() => _repository.getBackgrounds(), (data) => _backgrounds = data);

  Future<void> fetchFeats() async {
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

  // ─── Reset ────────────────────────────────────────────────────────────────
  void resetCreation() {
    _name = '';
    _level = 1;
    _selectedRace = _selectedClass = _selectedBackground = null;
    _racialBonuses.clear();
    _levelUpChoices.clear();
    _featChoices.clear();
    baseStats = {
      'Strength': 10,
      'Dexterity': 10,
      'Constitution': 10,
      'Intelligence': 10,
      'Wisdom': 10,
      'Charisma': 10,
    };
    _maxHp = 0;
    _speed = 30;

    skillVM.reset();
    equipmentVM.reset();
    languageVM.reset();
    notifyListeners();
  }

  // ─── Privados ─────────────────────────────────────────────────────────────
  void _calculateMaxHp() {
    if (_selectedClass == null) return;
    final die = int.tryParse(_selectedClass!.hit_dice) ?? 8;
    final con = getModifier('Constitution');
    _maxHp =
        die +
        con +
        (_level > 1 ? ((die / 2).floor() + 1 + con) * (_level - 1) : 0);
  }

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

  List<String> _parseList(dynamic data) {
    if (data == null || data.toString().isEmpty || data == 'null') return [];
    return data.toString().split(',').map((e) => e.trim()).toList();
  }

  String _cleanProficiencyText(String text) {
    final clean = text.replaceAll(RegExp(r'\*'), '').trim();
    return clean.length > 80 ? '${clean.substring(0, 77)}…' : clean;
  }

  // ─── Parsers de traits raciales ───────────────────────────────────────────
  static const _knownWeapons = [
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

  static const _knownTools = [
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

  List<String> _extractWeaponProfsFromTraits(String traits) {
    final weapons = <String>{};
    final lower = traits.toLowerCase();
    final pattern = RegExp(r'proficiency with ([^.\n]+)', caseSensitive: false);
    for (final match in pattern.allMatches(lower)) {
      final found = match.group(1) ?? '';
      if (found.contains('weapon') ||
          _knownWeapons.any((w) => found.contains(w))) {
        final clean = found
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'[*_]'), '')
            .trim();
        for (final item in clean.split(RegExp(r',| and '))) {
          final t = item.trim();
          if (t.isNotEmpty &&
              (_knownWeapons.any((w) => t.contains(w)) ||
                  t.contains('weapon'))) {
            weapons.add(_titleCase(t));
          }
        }
      }
    }
    return weapons.toList();
  }

  List<String> _extractSkillProfsFromTraits(String traits) {
    final skills = <String>{};
    final pattern1 = RegExp(
      r'proficiency in (?:the )?(\w[\w\s]+?)(?:\s*skill|\.|,|\n)',
      caseSensitive: false,
    );
    final pattern2 = RegExp(
      r'proficiency in (?:two|one|three) skills? of your choice',
      caseSensitive: false,
    );
    for (final match in pattern1.allMatches(traits)) {
      final found = (match.group(1) ?? '').trim();
      if (CharacterSkillViewModel.allDndSkills.any(
        (s) => s.toLowerCase() == found.toLowerCase(),
      )) {
        skills.add(_titleCase(found));
      }
    }
    if (pattern2.hasMatch(traits.toLowerCase())) {
      skills.add('Two skills of your choice');
    }
    return skills.toList();
  }

  List<String> _extractToolProfsFromTraits(String traits) {
    final tools = <String>{};
    final lower = traits.toLowerCase();
    final pattern = RegExp(
      r'proficiency with (?:the )?([^.\n]+)',
      caseSensitive: false,
    );
    for (final match in pattern.allMatches(lower)) {
      final found = match.group(1) ?? '';
      for (final tool in _knownTools) {
        if (found.contains(tool)) tools.add(_titleCase(tool));
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
}

// ─── Modelo ───────────────────────────────────────────────────────────────────
class ResolvedFeatChoice {
  final String? chosenStat;
  final List<String> proficiencies;
  const ResolvedFeatChoice({this.chosenStat, this.proficiencies = const []});
}
