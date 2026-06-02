  import 'package:flutter/material.dart';
  
  Color getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('dragon')) return Colors.red.shade700;
    if (t.contains('undead')) return Colors.purple.shade900;
    if (t.contains('fiend')) return Colors.deepOrange.shade800;
    if (t.contains('beast')) return Colors.brown.shade600;
    if (t.contains('aberration')) return Colors.deepPurple;
    if (t.contains('celestial')) return Colors.amber.shade600;
    if (t.contains('construct')) return Colors.blueGrey;
    return Colors.teal.shade700; 
  }