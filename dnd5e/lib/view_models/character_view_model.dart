import 'package:flutter/material.dart';
import '../data/models/character_class.dart';
import '../data/repositories/character_repository.dart';

class CreateCharacterViewModel extends ChangeNotifier {
  final CharacterRepository _repository;

  CreateCharacterViewModel(this._repository);

  // --- ESTADO ---
  List<CharacterClass> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Datos del personaje en creación
  String _name = "";
  CharacterClass? _selectedClass;

  // --- GETTERS (Lo que la UI puede leer) ---
  List<CharacterClass> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CharacterClass? get selectedClass => _selectedClass;

  // --- MÉTODOS (Lo que la UI puede pedir) ---

  // Cargar las clases desde la API
  Future<void> fetchAvailableClasses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisa a la UI que muestre un cargando

    try {
      _classes = await _repository.getClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Avisa a la UI que ya terminó
    }
  }

  void updateName(String newName) {
    _name = newName;
    // No siempre hace falta notifyListeners aquí si solo guardamos el texto
  }

  void selectClass(CharacterClass charClass) {
    _selectedClass = charClass;
    notifyListeners(); // La UI resaltará la clase elegida
  }
}