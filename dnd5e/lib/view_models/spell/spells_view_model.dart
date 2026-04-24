import 'dart:async';
import 'package:flutter/material.dart';

class SpellsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<dynamic> _spells = []; // Cambiarás 'dynamic' por tu modelo Spell más adelante
  Timer? _debounce;

  bool get isLoading => _isLoading;
  List<dynamic> get spells => _spells;

  // Lógica de búsqueda con Debounce de 500ms
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchSpells(query);
    });
  }

  Future<void> searchSpells(String query) async {
    if (query.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    // Aquí irá la llamada al repository: _repository.searchSpells(query)
    await Future.delayed(const Duration(seconds: 1)); // Simulación
    
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}