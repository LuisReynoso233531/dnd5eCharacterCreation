import 'package:flutter/material.dart';
import '../../data/models/character_class.dart';

class CharacterEquipmentViewModel extends ChangeNotifier {
  // ─── Estado ───────────────────────────────────────────────────────────────
  List<String> _fixedEquipment = [];
  List<String> _backgroundEquipment = [];
  List<EquipmentPackage> _equipmentPackages = [];
  int _selectedPackageIndex = 0;
  

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<String> get fixedEquipment => _fixedEquipment;
  List<String> get backgroundEquipment => _backgroundEquipment;
  List<EquipmentPackage> get equipmentPackages => _equipmentPackages;
  int get selectedPackageIndex => _selectedPackageIndex;

  List<String> get totalEquipment => [
        ..._backgroundEquipment,
        ..._fixedEquipment,
        if (_equipmentPackages.isNotEmpty)
          ..._equipmentPackages[_selectedPackageIndex].items,
      ];

  // ─── Métodos públicos ─────────────────────────────────────────────────────
  void updateFromBackground(Map<String, dynamic>? background) {
    _backgroundEquipment = [];
    if (background?['equipment'] != null) {
      _backgroundEquipment.add(background!['equipment'].toString());
    }
    notifyListeners();
  }

  void updateFromClass(CharacterClass? charClass) {
    _parseEquipmentIntoPackages(charClass);
    notifyListeners();
  }

  void setPackageIndex(int index) {
    _selectedPackageIndex = index;
    notifyListeners();
  }

  void reset() {
    _fixedEquipment = [];
    _backgroundEquipment = [];
    _equipmentPackages = [];
    _selectedPackageIndex = 0;
    notifyListeners();
  }

  // ─── Lógica privada ───────────────────────────────────────────────────────
  void _parseEquipmentIntoPackages(CharacterClass? charClass) {
    _fixedEquipment = [];
    _equipmentPackages = [];
    _selectedPackageIndex = 0;

    if (charClass?.equipment == null) return;

    final groups = <String, List<String>>{'a': [], 'b': [], 'c': []};
    final lines = charClass!.equipment!.split('\n');

    for (final line in lines) {
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
        _fixedEquipment.add(clean);
      }
    }

    _equipmentPackages = groups.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => EquipmentPackage(letter: e.key.toUpperCase(), items: e.value))
        .toList();
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
}

// ─── Modelo ───────────────────────────────────────────────────────────────────
class EquipmentPackage {
  final String letter;
  final List<String> items;
  const EquipmentPackage({required this.letter, required this.items});
}