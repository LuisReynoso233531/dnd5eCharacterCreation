import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../view_models/character/character_view_model.dart';
import '../models/saved_character_state.dart';

class CharacterProgressionStorage {
  static const String _folderName = 'character_data';

  static Future<Directory> charactersDirectory() async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory('${baseDirectory.path}/$_folderName');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  static Future<List<SavedCharacterState>> listCharacters() async {
    final directory = await charactersDirectory();
    final files = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();

    final characters = <SavedCharacterState>[];

    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is! Map) continue;

        characters.add(
          SavedCharacterState.fromJson(Map<String, dynamic>.from(decoded)),
        );
      } catch (_) {
        // A damaged JSON must not prevent the other versions from loading.
      }
    }

    characters.sort((first, second) {
      final currentComparison = _boolScore(
        second.isCurrentVersion,
      ).compareTo(_boolScore(first.isCurrentVersion));

      if (currentComparison != 0) return currentComparison;

      final levelComparison = second.level.compareTo(first.level);
      if (levelComparison != 0) return levelComparison;

      return second.updatedAt.compareTo(first.updatedAt);
    });

    return characters;
  }

  static Future<SavedCharacterState?> loadCharacter(String id) async {
    if (id.trim().isEmpty) return null;

    final directory = await charactersDirectory();
    final file = File('${directory.path}/${_safeId(id)}.json');
    if (!await file.exists()) return null;

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return null;

      return SavedCharacterState.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  static Future<SavedCharacterState?> findByCurrentPdfPath(
    String pdfPath,
  ) async {
    final characters = await listCharacters();

    for (final character in characters) {
      if (character.currentPdfPath == pdfPath) return character;
    }

    return null;
  }

  static Future<SavedCharacterState> saveGeneratedCharacter({
    required CreateCharacterViewModel vm,
    required CharacterInventoryViewModel inventoryVM,
    required String pdfPath,
    DetailClassViewModel? detailVM,
    CharacterSubclassViewModel? subclassVM,
    CharacterSpellViewModel? spellVM,
    String playerName = '',
    String alignment = '',
    String temporaryHp = '',
    String personalityTraits = '',
    String ideals = '',
    String bonds = '',
    String flaws = '',
  }) async {
    final selectedClass = vm.selectedClass;
    final selectedRace = vm.selectedRace;

    if (selectedClass == null || selectedRace == null) {
      throw StateError(
        'A race and class are required before saving character progression.',
      );
    }

    final now = DateTime.now();
    final sourceId = vm.editingCharacterId;
    final source = sourceId == null ? null : await loadCharacter(sourceId);

    final createsLevelVersion =
        source != null && vm.isLevelUp && vm.level > source.level;

    final generatedRootId = '${_safeId(vm.name)}_${now.microsecondsSinceEpoch}';

    final sourceLineageId = source?.lineageId.trim() ?? '';
    final lineageId = sourceLineageId.isNotEmpty
        ? sourceLineageId
        : source?.id ?? generatedRootId;

    final id = createsLevelVersion
        ? '${_safeId(lineageId)}_level_${vm.level}_'
              '${now.microsecondsSinceEpoch}'
        : source?.id ?? sourceId ?? generatedRootId;

    final history = <CharacterPdfVersion>[
      if (!createsLevelVersion) ...?source?.pdfHistory,
    ];

    if (!history.any((version) => version.path == pdfPath)) {
      history.add(
        CharacterPdfVersion(level: vm.level, path: pdfPath, createdAt: now),
      );
    }

    history.sort((first, second) {
      final levelComparison = first.level.compareTo(second.level);
      if (levelComparison != 0) return levelComparison;
      return first.createdAt.compareTo(second.createdAt);
    });

    final state = SavedCharacterState(
      id: id,
      lineageId: lineageId,
      parentCharacterId: createsLevelVersion
          ? source!.id
          : source?.parentCharacterId,
      isCurrentVersion: createsLevelVersion
          ? true
          : source?.isCurrentVersion ?? true,
      name: vm.name,
      level: vm.level,
      raceData: Map<String, dynamic>.from(selectedRace),
      classData: Map<String, dynamic>.from(selectedClass.toJson()),
      backgroundData: vm.selectedBackground == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(vm.selectedBackground!),
      baseStats: Map<String, int>.from(vm.baseStats),
      levelUpChoices: {
        for (final entry in vm.levelUpChoices.entries)
          entry.key: Map<String, dynamic>.from(entry.value),
      },
      featChoices: {
        for (final entry in vm.featChoices.entries)
          entry.key: SavedFeatChoice(
            chosenStat: entry.value.chosenStat,
            proficiencies: List<String>.from(entry.value.proficiencies),
            languages: List<String>.from(entry.value.languages),
          ),
      },
      selectedDwarvenToolProficiency: vm.selectedDwarvenToolProficiency,
      selectedDraconicAncestry: vm.selectedDraconicAncestry == null
          ? null
          : Map<String, String>.from(vm.selectedDraconicAncestry!),
      selectedClassSkills: List<String>.from(vm.skillVM.selectedClassSkills),
      selectedExpertise: List<String>.from(vm.skillVM.selectedExpertise),
      selectedRacialLanguages: List<String>.from(
        vm.languageVM.selectedRacialLanguages,
      ),
      selectedBackgroundLanguages: List<String>.from(
        vm.languageVM.selectedBgLanguages,
      ),
      selectedFeatLanguages: List<String>.from(
        vm.languageVM.selectedFeatLanguages,
      ),
      selectedEquipmentPackageIndex: vm.equipmentVM.selectedPackageIndex,
      hpRolls: detailVM == null
          ? Map<int, int>.from(source?.hpRolls ?? const <int, int>{})
          : Map<int, int>.from(detailVM.hpRolls),
      selectedArchetype: detailVM?.selectedArchetype == null
          ? source?.selectedArchetype
          : Map<String, dynamic>.from(detailVM!.selectedArchetype!),
      selectedFightingStyle: detailVM?.selectedFightingStyle == null
          ? source?.selectedFightingStyle
          : Map<String, String>.from(detailVM!.selectedFightingStyle!),
      selectedFightingStyleName:
          detailVM?.selectedFightingStyleName ??
          source?.selectedFightingStyleName,
      selectedBonusSkills: subclassVM == null
          ? List<String>.from(source?.selectedBonusSkills ?? const <String>[])
          : List<String>.from(subclassVM.selectedBonusSkills),
      selectedSpellTableId:
          subclassVM?.selectedSpellTableId ?? source?.selectedSpellTableId,
      selectedSpells: spellVM == null
          ? {
              for (final entry
                  in (source?.selectedSpells ?? const <int, List<String>>{})
                      .entries)
                entry.key: List<String>.from(entry.value),
            }
          : {
              for (final entry in spellVM.selectedSpells.entries)
                entry.key: List<String>.from(entry.value),
            },
      equippedArmorSlug: inventoryVM.equippedArmor?.slug,
      equippedShieldSlug: inventoryVM.equippedShield?.slug,
      weaponQuantities: {
        for (final entry in inventoryVM.weaponEntries)
          entry.weapon.slug: entry.quantity,
      },
      tools: List<String>.from(inventoryVM.tools),
      money: {
        'gp': inventoryVM.gp,
        'pp': inventoryVM.pp,
        'ep': inventoryVM.ep,
        'sp': inventoryVM.sp,
        'cp': inventoryVM.cp,
      },
      treasuresText: inventoryVM.treasuresText,
      playerName: playerName,
      alignment: alignment,
      temporaryHp: temporaryHp,
      personalityTraits: personalityTraits,
      ideals: ideals,
      bonds: bonds,
      flaws: flaws,
      currentPdfPath: pdfPath,
      pdfHistory: history,
      createdAt: createsLevelVersion ? now : source?.createdAt ?? now,
      updatedAt: now,
    );

    await _writeState(state);

    if (createsLevelVersion) {
      await _markOtherLineageVersionsHistorical(
        lineageId,
        exceptCharacterId: state.id,
      );
    }

    return state;
  }

  static Future<void> deleteCharacterData(String id) async {
    if (id.trim().isEmpty) return;

    final deletedState = await loadCharacter(id);
    final directory = await charactersDirectory();
    final file = File('${directory.path}/${_safeId(id)}.json');

    if (await file.exists()) {
      await file.delete();
    }

    // Remove folders produced by the older snapshot implementation.
    final oldVersionsDirectory = Directory(
      '${directory.path}/${_safeId(id)}_versions',
    );
    if (await oldVersionsDirectory.exists()) {
      await oldVersionsDirectory.delete(recursive: true);
    }

    if (deletedState?.isCurrentVersion == true) {
      await _promoteLatestLineageVersion(deletedState!.lineageId);
    }
  }

  static Future<void> _markOtherLineageVersionsHistorical(
    String lineageId, {
    required String exceptCharacterId,
  }) async {
    final characters = await listCharacters();

    for (final character in characters) {
      if (character.id == exceptCharacterId ||
          character.lineageId != lineageId ||
          !character.isCurrentVersion) {
        continue;
      }

      await _writeState(character.copyWith(isCurrentVersion: false));
    }
  }

  static Future<void> _promoteLatestLineageVersion(String lineageId) async {
    final candidates = (await listCharacters())
        .where((character) => character.lineageId == lineageId)
        .toList();

    if (candidates.isEmpty) return;

    candidates.sort((first, second) {
      final levelComparison = second.level.compareTo(first.level);
      if (levelComparison != 0) return levelComparison;
      return second.updatedAt.compareTo(first.updatedAt);
    });

    final promoted = candidates.first;
    if (!promoted.isCurrentVersion) {
      await _writeState(promoted.copyWith(isCurrentVersion: true));
    }
  }

  static Future<void> _writeState(SavedCharacterState state) async {
    final directory = await charactersDirectory();
    final file = File('${directory.path}/${_safeId(state.id)}.json');
    final temporary = File('${file.path}.tmp');
    const encoder = JsonEncoder.withIndent('  ');

    await temporary.writeAsString(encoder.convert(state.toJson()), flush: true);

    if (await file.exists()) {
      await file.delete();
    }

    await temporary.rename(file.path);
  }

  static int _boolScore(bool value) => value ? 1 : 0;

  static String _safeId(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    return cleaned.isEmpty ? 'character' : cleaned;
  }
}
