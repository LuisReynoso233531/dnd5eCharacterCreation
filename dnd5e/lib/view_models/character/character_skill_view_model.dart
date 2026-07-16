import 'package:flutter/material.dart';
import '../../data/models/character_class.dart';

class CharacterSkillViewModel extends ChangeNotifier {
  // ─── Constantes ───────────────────────────────────────────────────────────
  static const List<String> allDndSkills = [
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

  static const String thievesToolsExpertise = "Thieves' Tools";

  // ─── Estado ───────────────────────────────────────────────────────────────
  List<SkillChoice> _skillChoices = [];
  List<String> _classFixedSkills = [];
  List<String> _bgFixedSkills = [];
  List<String> _selectedClassSkills = [];
  List<String> _selectedExpertise = [];

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<SkillChoice> get skillChoices => _skillChoices;
  List<String> get classFixedSkills => _classFixedSkills;
  List<String> get bgFixedSkills => _bgFixedSkills;
  List<String> get selectedClassSkills => _selectedClassSkills;
  List<String> get selectedExpertise => List.unmodifiable(_selectedExpertise);
  int get totalDropdowns => _skillChoices.fold(0, (sum, c) => sum + c.count);

  List<String> totalFixedSkills({List<String> racialSkillProfs = const []}) {
    return {
      ..._bgFixedSkills,
      ..._classFixedSkills,
      ...racialSkillProfs,
    }.toList();
  }

  /// Número total de elecciones de Pericia disponibles al nivel actual.
  ///
  /// Bard: 2 al nivel 3 y otras 2 al nivel 10.
  /// Rogue: 2 al nivel 1 y otras 2 al nivel 6.
  int expertiseChoiceCount({
    required String classSlug,
    required int characterLevel,
  }) {
    final slug = classSlug.toLowerCase().trim();

    if (slug == 'bard') {
      if (characterLevel >= 10) return 4;
      if (characterLevel >= 3) return 2;
      return 0;
    }

    if (slug == 'rogue') {
      if (characterLevel >= 6) return 4;
      if (characterLevel >= 1) return 2;
      return 0;
    }

    return 0;
  }

  bool hasExpertise(String proficiency) {
    final target = proficiency.toLowerCase().trim();
    return _selectedExpertise.any(
      (item) => item.toLowerCase().trim() == target,
    );
  }

  // ─── Métodos públicos ─────────────────────────────────────────────────────
  void updateFromSelections({
    Map<String, dynamic>? background,
    CharacterClass? charClass,
  }) {
    _skillChoices = [];
    _classFixedSkills = [];
    _bgFixedSkills = [];
    _selectedClassSkills = [];
    _selectedExpertise = [];

    if (background != null) {
      _processSkillText(
        background['skill_proficiencies'] ?? '',
        isBackground: true,
      );
    }
    if (charClass != null) {
      _processSkillText(charClass.prof_skills ?? '', isBackground: false);
    }

    notifyListeners();
  }

  void confirmClassSkills(List<String> selected) {
    _selectedClassSkills = selected;
    notifyListeners();
  }

  void setExpertiseAt({
    required int index,
    required String proficiency,
    required int maxChoices,
  }) {
    if (index < 0 || index >= maxChoices) return;

    final cleaned = proficiency.trim();
    if (cleaned.isEmpty) return;

    final current = List<String>.from(_selectedExpertise);
    while (current.length < maxChoices) {
      current.add('');
    }

    final isAlreadySelectedElsewhere = current.asMap().entries.any(
      (entry) =>
          entry.key != index &&
          entry.value.toLowerCase().trim() == cleaned.toLowerCase(),
    );

    if (isAlreadySelectedElsewhere) return;

    current[index] = cleaned;
    _selectedExpertise = current.take(maxChoices).toList();
    notifyListeners();
  }

  void clearExpertiseAt(int index) {
    if (index < 0 || index >= _selectedExpertise.length) return;

    final current = List<String>.from(_selectedExpertise);
    current[index] = '';
    _selectedExpertise = current;
    notifyListeners();
  }

  void reset() {
    _skillChoices = [];
    _classFixedSkills = [];
    _bgFixedSkills = [];
    _selectedClassSkills = [];
    _selectedExpertise = [];
    notifyListeners();
  }

  // ─── Lógica privada ───────────────────────────────────────────────────────
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
          ? List<String>.from(allDndSkills)
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

  List<String> _extractSkills(String text) => allDndSkills
      .where((s) => text.toLowerCase().contains(s.toLowerCase()))
      .toList();

  int _extractNumber(String text) {
    if (text.contains('4') || text.toLowerCase().contains('four')) return 4;
    if (text.contains('3') || text.toLowerCase().contains('three')) return 3;
    if (text.contains('2') || text.toLowerCase().contains('two')) return 2;
    return 1;
  }
}

// ─── Modelo ───────────────────────────────────────────────────────────────────
class SkillChoice {
  final List<String> options;
  final int count;
  const SkillChoice({required this.options, this.count = 1});
}
