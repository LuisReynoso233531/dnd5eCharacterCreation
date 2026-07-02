import 'package:flutter/material.dart';

class HpTrackerViewModel extends ChangeNotifier {
  int _maxHp = 0;
  int _currentHp = 0;
  
  // Guardará el historial solo con números y operaciones
  final List<String> _reportHistory = [];

  int get maxHp => _maxHp;
  int get currentHp => _currentHp;
  List<String> get reportHistory => _reportHistory;

  void setMaxHp(int value) {
    if (value < 0) return;
    _maxHp = value;
    _currentHp = value;
    
    // Formato: Max HP: 100
    _reportHistory.insert(0, "Max HP: $value");
    notifyListeners();
  }

  void applyDamage(int amount) {
    if (_maxHp == 0 || amount <= 0) return;
    
    final int oldHp = _currentHp;
    _currentHp = (_currentHp - amount).clamp(0, _maxHp);
    
    // Formato: -20 (100 ➔ 80)
    _reportHistory.insert(0, "-$amount ($oldHp ➔ $_currentHp)");
    notifyListeners();
  }

  void applyHealing(int amount) {
    if (_maxHp == 0 || amount <= 0) return;
    
    final int oldHp = _currentHp;
    _currentHp = (_currentHp + amount).clamp(0, _maxHp);
    
    // Formato: +15 (80 ➔ 95)
    _reportHistory.insert(0, "+$amount ($oldHp ➔ $_currentHp)");
    notifyListeners();
  }

  void reset() {
    _maxHp = 0;
    _currentHp = 0;
    _reportHistory.clear();
    notifyListeners();
  }
}