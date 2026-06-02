import 'package:flutter/material.dart';
import '../../data/repositories/bestiary_repository.dart';

class BestiaryViewModel extends ChangeNotifier {
  final BestiaryRepository _repository = BestiaryRepository();

  List<Map<String, dynamic>> _allMonsters = [];
  List<Map<String, dynamic>> _filteredMonsters = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? errorMessage;

  List<Map<String, dynamic>> get filteredMonsters => _filteredMonsters;
  bool get isLoading => _isLoading;

  BestiaryViewModel() {
    fetchMonsters();
  }

  Future<void> fetchMonsters() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? nextUrl;
      bool isFirstPage = true;

      // Este bucle seguirá corriendo en segundo plano hasta traer los 3000+
      do {
        // 1. Traemos la página actual (si es la primera, url será null)
        final data = await _repository.getMonstersPage(isFirstPage ? null : nextUrl);
        final newMonsters = List<Map<String, dynamic>>.from(data['results']);
        
        // 2. Los agregamos a nuestra lista maestra y ordenamos
        _allMonsters.addAll(newMonsters);
        _allMonsters.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
        
        // 3. Actualizamos la lista filtrada por si el usuario ya está buscando algo
        if (_searchQuery.isEmpty) {
          _filteredMonsters = List.from(_allMonsters);
        } else {
          _filteredMonsters = _allMonsters.where((monster) {
            final name = (monster['name'] ?? '').toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        // 4. Preparamos la siguiente URL (será null cuando lleguemos al final)
        nextUrl = data['next'];
        isFirstPage = false;
        
        // 5. Ocultamos el ícono de carga gigante en cuanto llegue la primera página
        if (_isLoading) {
          _isLoading = false;
        }
        
        // 6. Avisamos a la UI que hay nuevos monstruos disponibles
        notifyListeners();

      } while (nextUrl != null);

      debugPrint("¡Todos los monstruos han sido cargados en memoria!");

    } catch (e) {
      errorMessage = 'Connection interrupted. Showing partially loaded monsters.';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error en Bestiary: $e');
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (_searchQuery.isEmpty) {
      _filteredMonsters = _allMonsters;
    } else {
      _filteredMonsters = _allMonsters.where((monster) {
        final name = (monster['name'] ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}