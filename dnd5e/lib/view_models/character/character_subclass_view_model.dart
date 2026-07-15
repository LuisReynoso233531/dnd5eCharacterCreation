import 'package:flutter/material.dart';
import '../../data/models/subclass_spell_grant.dart';
import '../../utils/subclass_spell_parser.dart';
import 'character_detail_class_view_model.dart';
import 'character_skill_view_model.dart';

class SubclassProficiencyRule {
  final List<String> fixedSkills;
  final int chooseCount;
  final List<String>? options;
  final bool chooseAlternativeIfDuplicate;
  final List<String>? alternativeOptions;

  const SubclassProficiencyRule({
    this.fixedSkills = const [],
    this.chooseCount = 0,
    this.options,
    this.chooseAlternativeIfDuplicate = false,
    this.alternativeOptions,
  });
}

class CharacterSubclassViewModel extends ChangeNotifier {
  List<String> _automaticSkills = [];
  List<String> get automaticSkills => _automaticSkills;

  int _pendingChoicesCount = 0;
  int get pendingChoicesCount => _pendingChoicesCount;

  List<String> _availableOptionsForChoice = [];
  List<String> get availableOptionsForChoice => _availableOptionsForChoice;

  final List<String> _selectedBonusSkills = [];
  List<String> get selectedBonusSkills => _selectedBonusSkills;

  List<SubclassSpellTable> _spellTables = [];
  List<SubclassSpellTable> get spellTables => List.unmodifiable(_spellTables);

  String? _selectedSpellTableId;
  String? get selectedSpellTableId => _selectedSpellTableId;

  bool get requiresSpellTableChoice => _spellTables.length > 1;

  SubclassSpellTable? get selectedSpellTable {
    if (_selectedSpellTableId == null) return null;
    for (final table in _spellTables) {
      if (table.id == _selectedSpellTableId) return table;
    }
    return null;
  }

  static const Map<String, List<SubclassSpellGrant>> _fixedSpellGrants = {
    // En esta subclase Mage Hand forma parte de los cantrips conocidos.
    'eldritch-trickster': [
      SubclassSpellGrant(
        characterLevel: 3,
        spellName: 'Mage Hand',
        countsAgainstLimit: true,
      ),
    ],
    // Alias por si otra fuente usa el nombre estándar.
    'arcane-trickster': [
      SubclassSpellGrant(
        characterLevel: 3,
        spellName: 'Mage Hand',
        countsAgainstLimit: true,
      ),
    ],
    'underfoot': [
      SubclassSpellGrant(
        characterLevel: 3,
        spellName: 'Shillelagh',
        countsAgainstLimit: true,
      ),
    ],
  };

  String? _selectedArchetypeSlug;

  List<SubclassSpellGrant> grantedSpellsForLevel(int characterLevel) {
    final grants = <SubclassSpellGrant>[
      ...?selectedSpellTable?.grantsAvailableAt(characterLevel),
    ];

    final fixed = _fixedSpellGrants[_selectedArchetypeSlug] ?? const [];
    grants.addAll(
      fixed.where((grant) => grant.characterLevel <= characterLevel),
    );

    final seen = <String>{};
    return grants.where((grant) {
      final key = grant.spellName.toLowerCase().trim();
      return key.isNotEmpty && seen.add(key);
    }).toList(growable: false);
  }

  DetailClassViewModel? _detailClassVM;
  CharacterSkillViewModel? _skillVM;

  CharacterSubclassViewModel({
    DetailClassViewModel? detailClassVM,
    CharacterSkillViewModel? skillVM,
  }) : _detailClassVM = detailClassVM,
       _skillVM = skillVM;

  void updateDependencies({
    DetailClassViewModel? detailClassVM,
    CharacterSkillViewModel? skillVM,
  }) {
    if (detailClassVM != null) _detailClassVM = detailClassVM;
    if (skillVM != null) _skillVM = skillVM;
  }

  static const Map<String, SubclassProficiencyRule> _subclassRules = {
    'path-of-mistwood': SubclassProficiencyRule(
      fixedSkills: ['Stealth'],
      chooseAlternativeIfDuplicate: true,
      alternativeOptions: [
        'Animal Handling',
        'Athletics',
        'Intimidation',
        'Nature',
        'Perception',
        'Survival',
      ],
    ),
    'college-of-lore': SubclassProficiencyRule(chooseCount: 3),
    'legionary': SubclassProficiencyRule(
      chooseCount: 1,
      options: ['Insight', 'Nature', 'Survival'],
    ),
    'soulspy': SubclassProficiencyRule(
      fixedSkills: ['Religion'],
      chooseAlternativeIfDuplicate: false,
    ),
    'college-of-investigation': SubclassProficiencyRule(
      fixedSkills: ['Insight'],
      chooseAlternativeIfDuplicate: true,
      chooseCount: 2,
    ),
    'college-of-shadows': SubclassProficiencyRule(
      fixedSkills: ['Stealth'],
      chooseAlternativeIfDuplicate: false,
      chooseCount: 2,
    ),
    'college-of-the-cattle': SubclassProficiencyRule(
      fixedSkills: ['Stealth', 'Acrobatics'],
      chooseAlternativeIfDuplicate: false,
    ),
    'mercy-domain': SubclassProficiencyRule(
      fixedSkills: ['Medicine'],
      chooseAlternativeIfDuplicate: false,
    ),
  };

  void setArchetype(
    Map<String, dynamic>? archetype,
    List<String> existingSkills,
  ) {
    _detailClassVM?.selectArchetype(archetype ?? {});

    _automaticSkills = [];
    _selectedBonusSkills.clear();
    _pendingChoicesCount = 0;
    _availableOptionsForChoice = [];
    _spellTables = [];
    _selectedSpellTableId = null;
    _selectedArchetypeSlug = null;

    if (archetype == null) {
      notifyListeners();
      return;
    }

    _selectedArchetypeSlug =
        archetype['slug']?.toString().toLowerCase().trim();
    _spellTables = SubclassSpellParser.parse(archetype['desc']?.toString());
    if (_spellTables.length == 1) {
      _selectedSpellTableId = _spellTables.first.id;
    }

    final slug = archetype['slug']?.toString().toLowerCase() ?? '';
    final rule = _subclassRules[slug];

    if (rule != null) {
      for (final skill in rule.fixedSkills) {
        if (existingSkills.contains(skill)) {
          if (rule.chooseAlternativeIfDuplicate) {
            _pendingChoicesCount++;
            if (rule.alternativeOptions != null) {
              _availableOptionsForChoice.addAll(rule.alternativeOptions!);
            } else {
              _availableOptionsForChoice.addAll(
                CharacterSkillViewModel.allDndSkills,
              );
            }
          }
        } else {
          _automaticSkills.add(skill);
        }
      }

      if (rule.chooseCount > 0) {
        _pendingChoicesCount += rule.chooseCount;
        if (rule.options != null) {
          _availableOptionsForChoice.addAll(rule.options!);
        } else {
          _availableOptionsForChoice.addAll(
            CharacterSkillViewModel.allDndSkills,
          );
        }
      }

      _availableOptionsForChoice = _availableOptionsForChoice
          .toSet()
          .where(
            (skill) =>
                !existingSkills.contains(skill) &&
                !_automaticSkills.contains(skill),
          )
          .toList();
    }

    notifyListeners();
  }

  void selectSpellTable(String tableId) {
    if (!_spellTables.any((table) => table.id == tableId)) return;
    _selectedSpellTableId = tableId;
    notifyListeners();
  }

  void toggleBonusSkill(String skill) {
    if (_selectedBonusSkills.contains(skill)) {
      _selectedBonusSkills.remove(skill);
    } else if (_selectedBonusSkills.length < _pendingChoicesCount) {
      _selectedBonusSkills.add(skill);
    }
    notifyListeners();
  }
}
