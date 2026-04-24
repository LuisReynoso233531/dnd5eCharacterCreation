import 'package:flutter/material.dart';

class ToolsViewModel extends ChangeNotifier {
  // Las herramientas suelen ser locales (Dados, Calculadora)
  // Aquí puedes manejar el historial de tiradas de dados, por ejemplo.
  
  final List<Map<String, dynamic>> availableTools = [
    {'name': 'Dice Roller', 'icon': 'casino'},
    {'name': 'HP Tracker', 'icon': 'favorite'},
    {'name': 'Combat Tracker', 'icon': 'swords'},
    {'name': 'Notes', 'icon': 'edit_note'},
  ];
}