import 'package:flutter/material.dart';
import '../../data/models/character_class.dart';
import '../../data/repositories/character_repository.dart';

class CreateCharacterViewModel extends ChangeNotifier {
  final CharacterRepository _repository;

  CreateCharacterViewModel(this._repository);

  // --- ESTADO GENERAL ---
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- ESTADO DE DATOS (API) ---
  List<CharacterClass> _classes = [];
  List<Map<String, dynamic>> _races = [];
  
  List<CharacterClass> get classes => _classes;
  List<Map<String, dynamic>> get races => _races;

  // --- ESTADO DE SELECCIÓN (Personaje en creación) ---
  String _name = "";
  Map<String, dynamic>? _selectedRace;
  CharacterClass? _selectedClass;

  String get name => _name;
  Map<String, dynamic>? get selectedRace => _selectedRace;
  CharacterClass? get selectedClass => _selectedClass;

  // --- MÉTODOS ---

  // Carga de Razas con sistema de caché
  Future<void> fetchRaces() async {
    if (_races.isNotEmpty) return; // Si ya hay datos, no pedimos de nuevo

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _races = await _repository.getRaces();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carga de Clases con sistema de caché
  Future<void> fetchAvailableClasses() async {
    if (_classes.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await _repository.getClasses();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateName(String newName) {
    _name = newName;
  }

  void setRace(Map<String, dynamic> race) {
    _selectedRace = race;
    notifyListeners();
  }

  void selectClass(CharacterClass charClass) {
    _selectedClass = charClass;
    notifyListeners();
  }

  // Método para resetear el progreso si el usuario cancela
  void resetCreation() {
    _name = "";
    _selectedRace = null;
    _selectedClass = null;
    notifyListeners();
  }
}