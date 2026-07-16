import 'package:flutter/material.dart';

const schoolColors = {
  'abjuration': Color(0xFF1565C0),
  'conjuration': Color(0xFF6A1B9A),
  'divination': Color(0xFF00838F),
  'enchantment': Color(0xFFC62828),
  'evocation': Color(0xFFE65100),
  'illusion': Color(0xFF4527A0),
  'necromancy': Color(0xFF1B5E20),
  'transmutation': Color(0xFF558B2F),
};

Color schoolColor(String school, {bool isDark = false}) {
  final base = schoolColors[school.toLowerCase()] ?? Colors.blueGrey;
  return isDark ? Color.lerp(base, Colors.white, 0.38)! : base;
}
