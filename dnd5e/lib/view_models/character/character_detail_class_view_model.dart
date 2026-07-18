import 'package:flutter/material.dart';

class DetailClassViewModel extends ChangeNotifier {
  Map<String, dynamic>? _selectedArchetype;
  Map<String, dynamic>? get selectedArchetype => _selectedArchetype;
  Map<String, String>? _selectedFightingStyle;
  Map<String, String>? get selectedFightingStyle => _selectedFightingStyle;
  String? _selectedFightingStyleName; 
  String? get selectedFightingStyleName => _selectedFightingStyleName;
  final Map<int, int> _hpRolls = {};
  int _conModifier = 0;
  int _racialHpBonusPerLevel = 0;

  Map<int, int> get hpRolls => _hpRolls;
  int get conModifier => _conModifier;
  int get racialHpBonusPerLevel => _racialHpBonusPerLevel;

  static const Map<String, int> _subclassUnlockLevel = {
    'barbarian': 3,
    'bard': 3,
    'cleric': 1,
    'druid': 2,
    'fighter': 3,
    'monk': 3,
    'paladin': 3,
    'ranger': 3,
    'rogue': 3,
    'sorcerer': 1,
    'warlock': 1,
    'wizard': 2,
  };

  int subclassUnlockLevelFor(String classSlug) =>
      _subclassUnlockLevel[classSlug.toLowerCase()] ?? 3;

  bool canChooseSubclass(String classSlug, int characterLevel) =>
      characterLevel >= subclassUnlockLevelFor(classSlug);

  void selectArchetype(Map<String, dynamic> archetype) {
    _selectedArchetype = archetype.isEmpty ? null : archetype;
    notifyListeners();
  }

  void setConModifier(int mod) {
    if (_conModifier == mod) return;
    _conModifier = mod;
    notifyListeners();
  }

  void setRacialHpBonusPerLevel(int bonus) {
    final normalizedBonus = bonus < 0 ? 0 : bonus;
    if (_racialHpBonusPerLevel == normalizedBonus) return;

    _racialHpBonusPerLevel = normalizedBonus;
    notifyListeners();
  }

  void setFightingStyle(Map<String, String>? style) {
    _selectedFightingStyle = style;
    notifyListeners();
  }

  void setFightingStyleName(String? styleName) {
    _selectedFightingStyleName = styleName;
    notifyListeners();
  }

  void syncLevels(int currentLevel, int hitDieMax) {
    _hpRolls[1] = hitDieMax;

    for (int i = 2; i <= currentLevel; i++) {
      _hpRolls.putIfAbsent(i, () => (hitDieMax / 2).ceil());
    }

    _hpRolls.removeWhere((key, value) => key > currentLevel);
  }

  void updateRoll(int level, int newValue, int hitDieMax) {
    if (level == 1) return;
    if (newValue < 1 || newValue > hitDieMax) return;

    _hpRolls[level] = newValue;
    notifyListeners();
  }

  int calculateTotalHP({int? racialBonusPerLevel}) {
    if (_hpRolls.isEmpty) return 0;

    final diceSum = _hpRolls.values.fold(0, (sum, val) => sum + val);
    final conBonusTotal = _hpRolls.length * _conModifier;
    final effectiveRacialBonus =
        racialBonusPerLevel ?? _racialHpBonusPerLevel;
    final racialBonusTotal = _hpRolls.length * effectiveRacialBonus;

    return diceSum + conBonusTotal + racialBonusTotal;
  }

  int parseHitDie(String? hitDice) {
    if (hitDice == null) return 8;
    final clean = hitDice.toLowerCase().replaceAll('1d', '').trim();
    return int.tryParse(clean) ?? 8;
  }

  List<Map<String, String>> getUnlockedFeatures(dynamic charClass, int currentLevel) {
    if (charClass == null) return [];

    final String table = charClass.table ?? '';
    final String desc = charClass.desc ?? '';
    final String subtypesName = charClass.subtypes_name ?? ''; 

    Set<String> unlockedFeatureNames = {};

    // 1. Extraer nombres de la tabla (Esto se mantiene igual)
    final lines = table.split('\n');
    int featureCol = -1;
    for (var line in lines) {
      if (line.contains('| Level')) {
        final headers = line.split('|').map((e) => e.trim()).toList();
        featureCol = headers.indexOf('Features');
        break;
      }
    }

    if (featureCol != -1) {
      for (int i = 1; i <= currentLevel; i++) {
        String suffix = i == 1 ? 'st' : i == 2 ? 'nd' : i == 3 ? 'rd' : 'th';
        String levelStr = '$i$suffix';
        for (var line in lines) {
          if (line.startsWith('| $levelStr ') || line.startsWith('| $i ')) {
            final cols = line.split('|').map((e) => e.trim()).toList();
            if (cols.length > featureCol) {
              final featuresRaw = cols[featureCol];
              if (featuresRaw != '-' && featuresRaw.isNotEmpty) {
                final features = featuresRaw.split(',').map((e) => e.trim());
                for (var f in features) {
                  final lowerF = f.toLowerCase();
                  if (lowerF.contains('ability score improvement') || lowerF == 'asi') continue;
                  if (lowerF == 'spellcasting focus' || lowerF.contains('spellcasting focus')) continue;
                  if (subtypesName.isNotEmpty && lowerF.contains(subtypesName.toLowerCase())) continue;
                  unlockedFeatureNames.add(f);
                }
              }
            }
            break;
          }
        }
      }
    }

    // 2. LECTOR INTELIGENTE CON FILTRO DE SECCIÓN
    List<Map<String, String>> result = [];
    final descLines = desc.split('\n');
    
    String currentTitle = '';
    StringBuffer currentContent = StringBuffer();
    bool isIgnoringSection = false; // <--- NUEVA VARIABLE PARA FILTRAR

    void saveCurrentFeature() {
      if (currentTitle.isNotEmpty) {
        bool isUnlocked = unlockedFeatureNames.any((f) {
          final cleanF = f.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
          final cleanT = currentTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
          return cleanF == cleanT || cleanF.startsWith(cleanT) || cleanT.startsWith(cleanF);
        });

        if (isUnlocked) {
          String finalContent = currentContent.toString().replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '').trim();
          if (finalContent.isNotEmpty) {
            result.add({'title': currentTitle, 'desc': finalContent});
          }
        }
      }
    }

    for (var line in descLines) {
      final headerMatch = RegExp(r'^(#{2,5})\s+(.*)').firstMatch(line);
      
      if (headerMatch != null) {
        int level = headerMatch.group(1)!.length;
        String title = headerMatch.group(2)!.replaceAll('*', '').trim();
        String titleLower = title.toLowerCase();

        // --- LÓGICA DE EXCLUSIÓN ---
        if (titleLower.contains('preparing and casting spells')) {
          isIgnoringSection = true; // Empezamos a ignorar
          continue;
        }

        if (level <= 3) {
          saveCurrentFeature();
          isIgnoringSection = false; // Resetear al cambiar de rasgo principal
          currentTitle = title;
          currentContent = StringBuffer();
        } else {
          // Si es un subtítulo (####), dejamos de ignorar porque ya salimos de "Preparing..."
          isIgnoringSection = false; 
          if (currentTitle.isNotEmpty) {
            currentContent.writeln('\n• ${title.toUpperCase()}');
          }
        }
      } else {
        // Solo añadimos el texto si NO estamos en una sección ignorada
        if (currentTitle.isNotEmpty && !isIgnoringSection) {
          currentContent.writeln(line);
        }
      }
    }
    saveCurrentFeature();

    return result;
  }

  List<Map<String, String>> getAvailableFightingStyles(dynamic charClass, int currentLevel) {
    if (charClass == null) return [];

    // Validar si la clase tiene Fighting Style en su nivel actual
    final slug = charClass.slug.toString().toLowerCase();
    bool hasFightingStyle = false;

    if (slug == 'fighter' && currentLevel >= 1) hasFightingStyle = true;
    if ((slug == 'paladin' || slug == 'ranger') && currentLevel >= 2) hasFightingStyle = true;
    
    // Si no es ninguna de estas clases o no tiene el nivel, regresamos vacío
    if (!hasFightingStyle) return [];

    final desc = charClass.desc ?? '';
    List<Map<String, String>> styles = [];

    // Buscar el bloque de "Fighting Style" usando expresiones regulares
    final fsBlockRegex = RegExp(r'###\s+Fighting Style\b(.*?)(?=\n###\s+|$)', dotAll: true);
    final match = fsBlockRegex.firstMatch(desc);

    if (match != null) {
      final fsContent = match.group(1) ?? '';
      
      // Ahora buscamos todos los subtítulos (#### Nombre) dentro de ese bloque
      final styleRegex = RegExp(r'####\s+([^\n]+)\n(.*?)(?=\n####\s+|$)', dotAll: true);
      final styleMatches = styleRegex.allMatches(fsContent);

      for (final m in styleMatches) {
        final name = m.group(1)?.replaceAll(RegExp(r'\*|_'), '').trim() ?? '';
        final content = m.group(2)?.replaceAll(RegExp(r'\*|_'), '').trim() ?? '';
        if (name.isNotEmpty) {
          styles.add({'name': name, 'desc': content});
        }
      }
    }
    return styles;
  }

  void reset() {
    _selectedArchetype = null;
    _hpRolls.clear();
    _conModifier = 0;
    _racialHpBonusPerLevel = 0;
    notifyListeners();
  }
}
