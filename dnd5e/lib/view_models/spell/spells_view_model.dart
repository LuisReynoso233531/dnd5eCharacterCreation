import 'package:flutter/material.dart';
import '../../data/repositories/spells_repository.dart';

class SpellsViewModel extends ChangeNotifier {
  final SpellsRepository _repository = SpellsRepository();

  List<Map<String, dynamic>> _allSpells = [];
  List<Map<String, dynamic>> _filteredSpells = []; // Filtrados solo por Búsqueda
  bool _isLoading = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get filteredSpells => _filteredSpells;
  bool get isLoading => _isLoading;

  SpellsViewModel() {
    loadSpells();
  }

  Future<void> loadSpells() async {
    _isLoading = true;
    notifyListeners();

    try {
      final spells = await _repository.getSpells();
      spells.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
      _allSpells = spells;
      _filteredSpells = _allSpells;
    } catch (e) {
      debugPrint('Error loading spells: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredSpells = _allSpells;
    } else {
      _filteredSpells = _allSpells.where((spell) {
        final name = (spell['name'] ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredSpells = _allSpells;
    } else {
      _filteredSpells = _allSpells.where((spell) {
        final name = (spell['name'] ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}