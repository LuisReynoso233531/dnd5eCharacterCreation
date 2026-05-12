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

  // ─── Estado ───────────────────────────────────────────────────────────────
  List<SkillChoice> _skillChoices = [];
  List<String> _classFixedSkills = [];
  List<String> _bgFixedSkills = [];
  List<String> _selectedClassSkills = [];

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<SkillChoice> get skillChoices => _skillChoices;
  List<String> get classFixedSkills => _classFixedSkills;
  List<String> get bgFixedSkills => _bgFixedSkills;
  List<String> get selectedClassSkills => _selectedClassSkills;
  int get totalDropdowns => _skillChoices.fold(0, (sum, c) => sum + c.count);

  List<String> totalFixedSkills({List<String> racialSkillProfs = const []}) {
    return {
      ..._bgFixedSkills,
      ..._classFixedSkills,
      ...racialSkillProfs,
    }.toList();
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

  void reset() {
    _skillChoices = [];
    _classFixedSkills = [];
    _bgFixedSkills = [];
    _selectedClassSkills = [];
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