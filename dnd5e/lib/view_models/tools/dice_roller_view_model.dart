import 'dart:math';
import 'package:flutter/material.dart';

class DiceRollerViewModel extends ChangeNotifier {
  final List<int> _currentRolls = [];
  int _total = 0;
  final List<String> _rollHistory = [];

  // Getters
  List<int> get currentRolls => _currentRolls;
  int get total => _total;
  List<String> get rollHistory => _rollHistory;

  void rollDice(int quantity, int faces) {
    if (quantity <= 0 || faces <= 0) return;

    final int safeQuantity = quantity.clamp(1, 99);

    _currentRolls.clear();
    final random = Random();
    int sum = 0;

    for (int i = 0; i < safeQuantity; i++) {
      final int roll = random.nextInt(faces) + 1;
      _currentRolls.add(roll);
      sum += roll;
    }

    _total = sum;

    _rollHistory.insert(0, "${safeQuantity}d$faces ➔ $_currentRolls = $_total");
    notifyListeners();
  }

  /// Limpia la pantalla y el historial
  void reset() {
    _currentRolls.clear();
    _total = 0;
    _rollHistory.clear();
    notifyListeners();
  }
}