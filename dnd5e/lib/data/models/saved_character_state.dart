class SavedFeatChoice {
  const SavedFeatChoice({
    this.chosenStat,
    this.proficiencies = const [],
    this.languages = const [],
  });

  final String? chosenStat;
  final List<String> proficiencies;
  final List<String> languages;

  Map<String, dynamic> toJson() => {
    'chosenStat': chosenStat,
    'proficiencies': proficiencies,
    'languages': languages,
  };

  factory SavedFeatChoice.fromJson(Map<String, dynamic> json) {
    return SavedFeatChoice(
      chosenStat: json['chosenStat']?.toString(),
      proficiencies: _stringList(json['proficiencies']),
      languages: _stringList(json['languages']),
    );
  }
}

class CharacterPdfVersion {
  const CharacterPdfVersion({
    required this.level,
    required this.path,
    required this.createdAt,
  });

  final int level;
  final String path;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'level': level,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CharacterPdfVersion.fromJson(Map<String, dynamic> json) {
    return CharacterPdfVersion(
      level: _asInt(json['level'], fallback: 1),
      path: json['path']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class SavedCharacterState {
  const SavedCharacterState({
    required this.id,
    String? lineageId,
    this.parentCharacterId,
    this.isCurrentVersion = true,
    required this.name,
    required this.level,
    required this.raceData,
    required this.classData,
    required this.backgroundData,
    required this.baseStats,
    this.levelUpChoices = const {},
    this.featChoices = const {},
    this.selectedDwarvenToolProficiency,
    this.selectedDraconicAncestry,
    this.selectedClassSkills = const [],
    this.selectedExpertise = const [],
    this.selectedRacialLanguages = const [],
    this.selectedBackgroundLanguages = const [],
    this.selectedFeatLanguages = const [],
    this.selectedEquipmentPackageIndex = 0,
    this.hpRolls = const {},
    this.selectedArchetype,
    this.selectedFightingStyle,
    this.selectedFightingStyleName,
    this.selectedBonusSkills = const [],
    this.selectedSpellTableId,
    this.selectedSpells = const {},
    this.equippedArmorSlug,
    this.equippedShieldSlug,
    this.weaponQuantities = const {},
    this.tools = const [],
    this.money = const {},
    this.treasuresText = '',
    this.playerName = '',
    this.alignment = '',
    this.temporaryHp = '',
    this.personalityTraits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
    this.currentPdfPath,
    this.pdfHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  }) : lineageId = lineageId ?? id;

  final String id;

  /// Shared identifier for every saved version of the same character.
  final String lineageId;

  /// Version used as the starting point for this level-up.
  final String? parentCharacterId;

  /// Only one version in a lineage is marked as the current main version.
  /// Historical versions remain independently usable for another level-up.
  final bool isCurrentVersion;

  final String name;
  final int level;
  final Map<String, dynamic> raceData;
  final Map<String, dynamic> classData;
  final Map<String, dynamic> backgroundData;
  final Map<String, int> baseStats;
  final Map<int, Map<String, dynamic>> levelUpChoices;
  final Map<int, SavedFeatChoice> featChoices;
  final String? selectedDwarvenToolProficiency;
  final Map<String, String>? selectedDraconicAncestry;
  final List<String> selectedClassSkills;
  final List<String> selectedExpertise;
  final List<String> selectedRacialLanguages;
  final List<String> selectedBackgroundLanguages;
  final List<String> selectedFeatLanguages;
  final int selectedEquipmentPackageIndex;
  final Map<int, int> hpRolls;
  final Map<String, dynamic>? selectedArchetype;
  final Map<String, String>? selectedFightingStyle;
  final String? selectedFightingStyleName;
  final List<String> selectedBonusSkills;
  final String? selectedSpellTableId;
  final Map<int, List<String>> selectedSpells;
  final String? equippedArmorSlug;
  final String? equippedShieldSlug;
  final Map<String, int> weaponQuantities;
  final List<String> tools;
  final Map<String, int> money;
  final String treasuresText;
  final String playerName;
  final String alignment;
  final String temporaryHp;
  final String personalityTraits;
  final String ideals;
  final String bonds;
  final String flaws;
  final String? currentPdfPath;
  final List<CharacterPdfVersion> pdfHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get className => classData['name']?.toString() ?? '';
  String get classSlug => classData['slug']?.toString() ?? '';
  String get raceName => raceData['name']?.toString() ?? '';

  bool get canLevelUp => level < 20;

  SavedCharacterState copyWith({bool? isCurrentVersion}) {
    return SavedCharacterState(
      id: id,
      lineageId: lineageId,
      parentCharacterId: parentCharacterId,
      isCurrentVersion: isCurrentVersion ?? this.isCurrentVersion,
      name: name,
      level: level,
      raceData: Map<String, dynamic>.from(raceData),
      classData: Map<String, dynamic>.from(classData),
      backgroundData: Map<String, dynamic>.from(backgroundData),
      baseStats: Map<String, int>.from(baseStats),
      levelUpChoices: {
        for (final entry in levelUpChoices.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      },
      featChoices: Map<int, SavedFeatChoice>.from(featChoices),
      selectedDwarvenToolProficiency: selectedDwarvenToolProficiency,
      selectedDraconicAncestry: selectedDraconicAncestry == null
          ? null
          : Map<String, String>.from(selectedDraconicAncestry!),
      selectedClassSkills: List<String>.from(selectedClassSkills),
      selectedExpertise: List<String>.from(selectedExpertise),
      selectedRacialLanguages: List<String>.from(selectedRacialLanguages),
      selectedBackgroundLanguages: List<String>.from(
        selectedBackgroundLanguages,
      ),
      selectedFeatLanguages: List<String>.from(selectedFeatLanguages),
      selectedEquipmentPackageIndex: selectedEquipmentPackageIndex,
      hpRolls: Map<int, int>.from(hpRolls),
      selectedArchetype: selectedArchetype == null
          ? null
          : Map<String, dynamic>.from(selectedArchetype!),
      selectedFightingStyle: selectedFightingStyle == null
          ? null
          : Map<String, String>.from(selectedFightingStyle!),
      selectedFightingStyleName: selectedFightingStyleName,
      selectedBonusSkills: List<String>.from(selectedBonusSkills),
      selectedSpellTableId: selectedSpellTableId,
      selectedSpells: {
        for (final entry in selectedSpells.entries)
          entry.key: List<String>.from(entry.value),
      },
      equippedArmorSlug: equippedArmorSlug,
      equippedShieldSlug: equippedShieldSlug,
      weaponQuantities: Map<String, int>.from(weaponQuantities),
      tools: List<String>.from(tools),
      money: Map<String, int>.from(money),
      treasuresText: treasuresText,
      playerName: playerName,
      alignment: alignment,
      temporaryHp: temporaryHp,
      personalityTraits: personalityTraits,
      ideals: ideals,
      bonds: bonds,
      flaws: flaws,
      currentPdfPath: currentPdfPath,
      pdfHistory: List<CharacterPdfVersion>.from(pdfHistory),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': 2,
    'id': id,
    'lineageId': lineageId,
    'parentCharacterId': parentCharacterId,
    'isCurrentVersion': isCurrentVersion,
    'name': name,
    'level': level,
    'raceData': raceData,
    'classData': classData,
    'backgroundData': backgroundData,
    'baseStats': baseStats,
    'levelUpChoices': {
      for (final entry in levelUpChoices.entries) '${entry.key}': entry.value,
    },
    'featChoices': {
      for (final entry in featChoices.entries)
        '${entry.key}': entry.value.toJson(),
    },
    'selectedDwarvenToolProficiency': selectedDwarvenToolProficiency,
    'selectedDraconicAncestry': selectedDraconicAncestry,
    'selectedClassSkills': selectedClassSkills,
    'selectedExpertise': selectedExpertise,
    'selectedRacialLanguages': selectedRacialLanguages,
    'selectedBackgroundLanguages': selectedBackgroundLanguages,
    'selectedFeatLanguages': selectedFeatLanguages,
    'selectedEquipmentPackageIndex': selectedEquipmentPackageIndex,
    'hpRolls': {
      for (final entry in hpRolls.entries) '${entry.key}': entry.value,
    },
    'selectedArchetype': selectedArchetype,
    'selectedFightingStyle': selectedFightingStyle,
    'selectedFightingStyleName': selectedFightingStyleName,
    'selectedBonusSkills': selectedBonusSkills,
    'selectedSpellTableId': selectedSpellTableId,
    'selectedSpells': {
      for (final entry in selectedSpells.entries) '${entry.key}': entry.value,
    },
    'equippedArmorSlug': equippedArmorSlug,
    'equippedShieldSlug': equippedShieldSlug,
    'weaponQuantities': weaponQuantities,
    'tools': tools,
    'money': money,
    'treasuresText': treasuresText,
    'playerName': playerName,
    'alignment': alignment,
    'temporaryHp': temporaryHp,
    'personalityTraits': personalityTraits,
    'ideals': ideals,
    'bonds': bonds,
    'flaws': flaws,
    'currentPdfPath': currentPdfPath,
    'pdfHistory': pdfHistory.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SavedCharacterState.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';

    final levelChoices = <int, Map<String, dynamic>>{};
    final rawLevelChoices = json['levelUpChoices'];
    if (rawLevelChoices is Map) {
      for (final entry in rawLevelChoices.entries) {
        final level = int.tryParse(entry.key.toString());
        if (level != null && entry.value is Map) {
          levelChoices[level] = Map<String, dynamic>.from(entry.value as Map);
        }
      }
    }

    final featChoices = <int, SavedFeatChoice>{};
    final rawFeatChoices = json['featChoices'];
    if (rawFeatChoices is Map) {
      for (final entry in rawFeatChoices.entries) {
        final level = int.tryParse(entry.key.toString());
        if (level != null && entry.value is Map) {
          featChoices[level] = SavedFeatChoice.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }

    final hpRolls = <int, int>{};
    final rawHpRolls = json['hpRolls'];
    if (rawHpRolls is Map) {
      for (final entry in rawHpRolls.entries) {
        final level = int.tryParse(entry.key.toString());
        if (level != null) {
          hpRolls[level] = _asInt(entry.value);
        }
      }
    }

    final selectedSpells = <int, List<String>>{};
    final rawSelectedSpells = json['selectedSpells'];
    if (rawSelectedSpells is Map) {
      for (final entry in rawSelectedSpells.entries) {
        final level = int.tryParse(entry.key.toString());
        if (level != null) {
          selectedSpells[level] = _stringList(entry.value);
        }
      }
    }

    final rawHistory = json['pdfHistory'];
    final history = rawHistory is List
        ? rawHistory
              .whereType<Map>()
              .map(
                (item) => CharacterPdfVersion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <CharacterPdfVersion>[];

    final rawLineageId = json['lineageId']?.toString().trim() ?? '';

    return SavedCharacterState(
      id: id,
      lineageId: rawLineageId.isEmpty ? id : rawLineageId,
      parentCharacterId: json['parentCharacterId']?.toString(),
      isCurrentVersion: _asBool(json['isCurrentVersion'], fallback: true),
      name: json['name']?.toString() ?? '',
      level: _asInt(json['level'], fallback: 1),
      raceData: _dynamicMap(json['raceData']),
      classData: _dynamicMap(json['classData']),
      backgroundData: _dynamicMap(json['backgroundData']),
      baseStats: _intMap(json['baseStats']),
      levelUpChoices: levelChoices,
      featChoices: featChoices,
      selectedDwarvenToolProficiency: json['selectedDwarvenToolProficiency']
          ?.toString(),
      selectedDraconicAncestry: _nullableStringMap(
        json['selectedDraconicAncestry'],
      ),
      selectedClassSkills: _stringList(json['selectedClassSkills']),
      selectedExpertise: _stringList(json['selectedExpertise']),
      selectedRacialLanguages: _stringList(json['selectedRacialLanguages']),
      selectedBackgroundLanguages: _stringList(
        json['selectedBackgroundLanguages'],
      ),
      selectedFeatLanguages: _stringList(json['selectedFeatLanguages']),
      selectedEquipmentPackageIndex: _asInt(
        json['selectedEquipmentPackageIndex'],
      ),
      hpRolls: hpRolls,
      selectedArchetype: _nullableDynamicMap(json['selectedArchetype']),
      selectedFightingStyle: _nullableStringMap(json['selectedFightingStyle']),
      selectedFightingStyleName: json['selectedFightingStyleName']?.toString(),
      selectedBonusSkills: _stringList(json['selectedBonusSkills']),
      selectedSpellTableId: json['selectedSpellTableId']?.toString(),
      selectedSpells: selectedSpells,
      equippedArmorSlug: json['equippedArmorSlug']?.toString(),
      equippedShieldSlug: json['equippedShieldSlug']?.toString(),
      weaponQuantities: _intMap(json['weaponQuantities']),
      tools: _stringList(json['tools']),
      money: _intMap(json['money']),
      treasuresText: json['treasuresText']?.toString() ?? '',
      playerName: json['playerName']?.toString() ?? '',
      alignment: json['alignment']?.toString() ?? '',
      temporaryHp: json['temporaryHp']?.toString() ?? '',
      personalityTraits: json['personalityTraits']?.toString() ?? '',
      ideals: json['ideals']?.toString() ?? '',
      bonds: json['bonds']?.toString() ?? '',
      flaws: json['flaws']?.toString() ?? '',
      currentPdfPath: json['currentPdfPath']?.toString(),
      pdfHistory: history,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  if (normalized == 'true') return true;
  if (normalized == 'false') return false;
  return fallback;
}

List<String> _stringList(dynamic value) {
  if (value is! Iterable) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

Map<String, dynamic> _dynamicMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

Map<String, dynamic>? _nullableDynamicMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

Map<String, String>? _nullableStringMap(dynamic value) {
  if (value is! Map) return null;
  return {
    for (final entry in value.entries)
      entry.key.toString(): entry.value.toString(),
  };
}

Map<String, int> _intMap(dynamic value) {
  if (value is! Map) return <String, int>{};
  return {
    for (final entry in value.entries)
      entry.key.toString(): _asInt(entry.value),
  };
}
