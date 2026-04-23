import 'package:flutter/material.dart';

class BestiaryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _monsters = [];

  bool get isLoading => _isLoading;
  List<dynamic> get monsters => _monsters;

  Future<void> fetchMonsters() async {
    _isLoading = true;
    notifyListeners();

    // Lógica para traer monstruos de la API
    
    _isLoading = false;
    notifyListeners();
  }
}