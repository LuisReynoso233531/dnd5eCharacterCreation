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
  List<Map<String, dynamic>> _displayRaces = []; 
  
  List<CharacterClass> get classes => _classes;
  List<Map<String, dynamic>> get races => _displayRaces;

  // --- ESTADO DE SELECCIÓN ---
  String _name = "";
  Map<String, dynamic>? _selectedRace;
  CharacterClass? _selectedClass;

  String get name => _name;
  Map<String, dynamic>? get selectedRace => _selectedRace;
  CharacterClass? get selectedClass => _selectedClass;

  // --- ACUMULADORES DE ATRIBUTOS Y RASGOS ---
  Map<String, int> _racialBonuses = {};
  List<String> _proficiencies = [];
  
  // Nuevos campos para almacenar datos de raza y subraza
  int _speed = 30;
  String _vision = "";
  String _languagesText = "";
  String _traitsSummary = "";

  // Getters para la UI
  Map<String, int> get racialBonuses => _racialBonuses;
  int get speed => _speed;
  String get vision => _vision;
  String get languagesText => _languagesText;
  String get traitsSummary => _traitsSummary;

  // Puntos base para la pantalla de Stats
  Map<String, int> baseStats = {
    'Strength': 10,
    'Dexterity': 10,
    'Constitution': 10,
    'Intelligence': 10,
    'Wisdom': 10,
    'Charisma': 10,
  };

  // --- MÉTODOS DE CARGA ---

  Future<void> fetchRaces() async {
    if (_displayRaces.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawRaces = await _repository.getRaces();
      List<Map<String, dynamic>> processed = [];

      for (var baseRace in rawRaces) {
        final subraces = baseRace['subraces'] as List<dynamic>?;

        if (subraces == null || subraces.isEmpty) {
          // Si no tiene subrazas, usamos los datos base
          processed.add(baseRace);
        } else {
          // Si tiene subrazas, creamos una entrada combinada por cada una
          for (var sub in subraces) {
            processed.add({
              'name': "${baseRace['name']} (${sub['name']})",
              'slug': sub['slug'],
              'desc': sub['desc'],
              // Combinamos visión, lenguajes y rasgos si la subraza aporta algo extra
              'vision': sub['vision'] ?? baseRace['vision'],
              'speed': sub['speed'] ?? baseRace['speed'],
              'languages': sub['languages'] ?? baseRace['languages'],
              'asi': [...(baseRace['asi'] ?? []), ...(sub['asi'] ?? [])],
              'traits': "${baseRace['traits'] ?? ''}\n\n${sub['traits'] ?? ''}",
              'is_subrace': true,
              'base_race_name': baseRace['name'],
            });
          }
        }
      }
      _displayRaces = processed;
    } catch (e) {
      _errorMessage = "Error al conectar con la API de Open5e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  // --- MÉTODOS DE SELECCIÓN ---

  void setRace(Map<String, dynamic> raceData) {
    _selectedRace = raceData;
    
    // 1. Reset y cálculo de bonos de atributos (ASI)
    _racialBonuses.clear();
    final List<dynamic> combinedAsi = raceData['asi'] ?? [];
    for (var bonus in combinedAsi) {
      final attr = bonus['attributes'][0].toString();
      final value = bonus['value'] as int;
      _racialBonuses[attr] = (_racialBonuses[attr] ?? 0) + value;
    }

    // 2. Almacenar Velocidad (parsing del objeto speed: {walk: X})
    if (raceData['speed'] != null && raceData['speed']['walk'] != null) {
      _speed = raceData['speed']['walk'];
    } else {
      _speed = 30; // Valor por defecto
    }

    // 3. Almacenar visión, lenguajes y rasgos acumulados
    _vision = raceData['vision'] ?? "Normal vision";
    _languagesText = raceData['languages'] ?? "Common";
    _traitsSummary = raceData['traits'] ?? "";

    notifyListeners();
  }

  void selectClass(CharacterClass charClass) {
    _selectedClass = charClass;
    notifyListeners();
  }
  
  

  // Lógica de cálculo de estadísticas para la siguiente pantalla
  int getTotalStat(String statName) {
    return (baseStats[statName] ?? 10) + (_racialBonuses[statName] ?? 0);
  }

  void updateBaseStat(String statName, int newValue) {
    baseStats[statName] = newValue;
    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void resetCreation() {
    _name = "";
    _selectedRace = null;
    _selectedClass = null;
    _speed = 30;
    _vision = "";
    _languagesText = "";
    _traitsSummary = "";
    baseStats = {
      'Strength': 10,
      'Dexterity': 10,
      'Constitution': 10,
      'Intelligence': 10,
      'Wisdom': 10,
      'Charisma': 10,
    };
    _racialBonuses.clear();
    notifyListeners();
  }
}