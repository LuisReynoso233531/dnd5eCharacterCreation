import '../../models/spell_model.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../view_models/character/character_inventory_view_model.dart';
import '../../../view_models/character/character_spell_view_model.dart';
import '../../../view_models/character/character_detail_class_view_model.dart';
import '../../../view_models/character/character_subclass_view_model.dart';
import 'pdf_feature_text_policy.dart';
import '../../../utils/spellcasting_source.dart';

import 'character_sheet_data.dart';
import 'character_sheet_text_utils.dart';

class CharacterSheetBuilder {
  static CharacterSheetData build({
    required CreateCharacterViewModel vm,
    required CharacterInventoryViewModel invVM,
    CharacterSpellViewModel? spellVM,
    DetailClassViewModel? detailVM,
    CharacterSubclassViewModel? subclassVM,
    String playerName = '',
    String alignment = '',
    String temporaryHp = '',
    String personalityTraits = '',
    String ideals = '',
    String bonds = '',
    String flaws = '',
  }) {
    final profBonus = CreateCharacterViewModel.proficiencyBonus(vm.level);
    final charClass = vm.selectedClass;
    final spellSource = charClass == null
        ? null
        : SpellcastingSourceResolver.resolve(
            characterClass: charClass,
            characterLevel: vm.level,
            archetype: detailVM?.selectedArchetype,
          );

    final strMod = vm.getModifier('Strength');
    final dexMod = vm.getModifier('Dexterity');
    final conMod = vm.getModifier('Constitution');
    final intMod = vm.getModifier('Intelligence');
    final wisMod = vm.getModifier('Wisdom');
    final chaMod = vm.getModifier('Charisma');

    final ac = invVM.calculateTotalAC(
      characterClass: charClass,
      dexMod: dexMod,
      conMod: conMod,
      wisMod: wisMod,
    );

    final stText = (charClass?.prof_saving_throws ?? '').toLowerCase();

    final stProfs = <String, bool>{
      'strength': stText.contains('strength'),
      'dexterity': stText.contains('dexterity'),
      'constitution': stText.contains('constitution'),
      'intelligence': stText.contains('intelligence'),
      'wisdom': stText.contains('wisdom'),
      'charisma': stText.contains('charisma'),
    };

    final stValues = <String, int>{
      'strength': strMod + (stProfs['strength']! ? profBonus : 0),
      'dexterity': dexMod + (stProfs['dexterity']! ? profBonus : 0),
      'constitution': conMod + (stProfs['constitution']! ? profBonus : 0),
      'intelligence': intMod + (stProfs['intelligence']! ? profBonus : 0),
      'wisdom': wisMod + (stProfs['wisdom']! ? profBonus : 0),
      'charisma': chaMod + (stProfs['charisma']! ? profBonus : 0),
    };

    final subclassSkills = <String>{
      ...(subclassVM?.automaticSkills ?? []),
      ...(subclassVM?.selectedBonusSkills ?? []),
    }.map((s) => s.toLowerCase()).toSet();

    final allSkillProfs =
        <String>{
              ...vm.skillVM.classFixedSkills,
              ...vm.skillVM.bgFixedSkills,
              ...vm.skillVM.selectedClassSkills,
              ...vm.racialSkillProficiencies,
              ...subclassSkills,
            }
            .where((skill) => skill.trim().isNotEmpty)
            .map((skill) => skill.toLowerCase().trim())
            .toSet();

    // Solo una habilidad ya competente puede recibir Pericia. La opción de
    // Thieves' Tools se conserva para mostrarla en la sección de competencias,
    // pero no tiene un campo numérico propio en la hoja estándar.
    final maxExpertiseChoices = charClass == null
        ? 0
        : vm.skillVM.expertiseChoiceCount(
            classSlug: charClass.slug,
            characterLevel: vm.level,
          );

    final expertiseChoices = vm.skillVM.selectedExpertise
        .where((item) => item.trim().isNotEmpty)
        .take(maxExpertiseChoices)
        .toSet();

    final expertiseSkills = expertiseChoices
        .map((item) => item.toLowerCase().trim())
        .where(allSkillProfs.contains)
        .toSet();

    int skillVal(String skill, String stat) {
      final mod = vm.getModifier(stat);
      final key = skill.toLowerCase();

      if (expertiseSkills.contains(key)) {
        return mod + (profBonus * 2);
      }

      if (allSkillProfs.contains(key)) {
        return mod + profBonus;
      }

      return mod;
    }

    final skillValues = <String, int>{
      'acrobatics': skillVal('Acrobatics', 'Dexterity'),
      'animal handling': skillVal('Animal Handling', 'Wisdom'),
      'arcana': skillVal('Arcana', 'Intelligence'),
      'athletics': skillVal('Athletics', 'Strength'),
      'deception': skillVal('Deception', 'Charisma'),
      'history': skillVal('History', 'Intelligence'),
      'insight': skillVal('Insight', 'Wisdom'),
      'intimidation': skillVal('Intimidation', 'Charisma'),
      'investigation': skillVal('Investigation', 'Intelligence'),
      'medicine': skillVal('Medicine', 'Wisdom'),
      'nature': skillVal('Nature', 'Intelligence'),
      'perception': skillVal('Perception', 'Wisdom'),
      'performance': skillVal('Performance', 'Charisma'),
      'persuasion': skillVal('Persuasion', 'Charisma'),
      'religion': skillVal('Religion', 'Intelligence'),
      'sleight of hand': skillVal('Sleight of Hand', 'Dexterity'),
      'stealth': skillVal('Stealth', 'Dexterity'),
      'survival': skillVal('Survival', 'Wisdom'),
    };

    final perceptionProficiencyMultiplier =
        expertiseSkills.contains('perception')
        ? 2
        : allSkillProfs.contains('perception')
        ? 1
        : 0;

    final passivePerception =
        10 + wisMod + (profBonus * perceptionProficiencyMultiplier);

    final weapons = invVM.weaponEntries;

    int weaponAbilityModifier(WeaponEntry e) {
      final props = e.weapon.properties.map((p) => p.toLowerCase()).toList();

      final isFinesse = props.any((p) => p.contains('finesse'));
      final isRanged = e.weapon.isRanged;

      if (isFinesse) {
        return strMod > dexMod ? strMod : dexMod;
      }

      if (isRanged) {
        return dexMod;
      }

      return strMod;
    }

    String _shortDamageType(String type) {
      final t = type.toLowerCase().trim();

      if (t.contains('slashing')) return 'S';
      if (t.contains('piercing')) return 'P';
      if (t.contains('bludgeoning')) return 'B';

      if (t.contains('fire')) return 'Fire';
      if (t.contains('cold')) return 'Cold';
      if (t.contains('acid')) return 'Acid';
      if (t.contains('poison')) return 'Pois.';
      if (t.contains('lightning')) return 'Light.';
      if (t.contains('thunder')) return 'Thun.';
      if (t.contains('necrotic')) return 'Necr.';
      if (t.contains('radiant')) return 'Rad.';
      if (t.contains('psychic')) return 'Psych.';
      if (t.contains('force')) return 'Force';

      return type.length > 6 ? '${type.substring(0, 6)}.' : type;
    }

    String weaponAttackBonus(WeaponEntry e) {
      final abilityMod = weaponAbilityModifier(e);

      // Por ahora se suma proficiency siempre, como pediste:
      // Fuerza/Destreza + proficiency.
      return CharacterSheetTextUtils.sign(abilityMod + profBonus);
    }

    String weaponDamage(WeaponEntry e) {
      final abilityMod = weaponAbilityModifier(e);

      final dice = e.weapon.damageDice.trim().isNotEmpty
          ? e.weapon.damageDice.trim()
          : '-';

      final damageType = _shortDamageType(e.weapon.damageType);

      final mod = abilityMod == 0
          ? ''
          : CharacterSheetTextUtils.sign(abilityMod);

      return '$dice$mod $damageType'.trim();
    }

    final weaponSlots = List<WeaponEntry?>.generate(
      3,
      (i) => i < weapons.length ? weapons[i] : null,
    );

    final equipLines = _buildEquipmentLines(invVM, weapons);
    final profLines = _buildProficiencyLines(
      vm,
      subclassSkills,
      expertiseChoices,
    );
    final page1Features = _buildPage1Features(vm);
    final page2Features = _buildPage2Features(
      vm: vm,
      detailVM: detailVM,
      charClass: charClass,
    );

    final spellInfo = _buildSpellInfo(vm, profBonus, spellSource);
    final spellsByLevel = _buildSpellsByLevel(spellVM);
    final slotCounts = _buildSlotCounts(vm, spellVM, spellSource);

    final manualHp =
        detailVM?.calculateTotalHP(
          racialBonusPerLevel: vm.racialHitPointBonusPerLevel,
        ) ??
        0;
    final sheetMaxHp = manualHp > 0 ? manualHp : vm.maxHp;

    return CharacterSheetData(
      characterName: vm.name,
      classLevel: '${charClass?.name ?? ''} ${vm.level}',
      race: vm.selectedRace?['name'] ?? '',
      background: vm.selectedBackground?['name'] ?? '',
      className: spellSource?.displayName ?? charClass?.name ?? '',
      playerName: playerName,
      alignment: alignment,
      temporaryHp: temporaryHp,
      str: vm.getTotalStat('Strength'),
      dex: vm.getTotalStat('Dexterity'),
      con: vm.getTotalStat('Constitution'),
      intel: vm.getTotalStat('Intelligence'),
      wis: vm.getTotalStat('Wisdom'),
      cha: vm.getTotalStat('Charisma'),
      strMod: strMod,
      dexMod: dexMod,
      conMod: conMod,
      intMod: intMod,
      wisMod: wisMod,
      chaMod: chaMod,
      profBonus: profBonus,
      ac: ac,
      initiative: dexMod,
      speed: vm.speed,
      hpMax: sheetMaxHp,
      passivePerception: passivePerception,
      hitDice: '${vm.level}d${charClass?.hit_dice ?? '8'}',
      stProficiency: stProfs,
      stValues: stValues,
      skillProficiencies: allSkillProfs,
      skillValues: skillValues,
      wpn1Name: weaponSlots[0]?.weapon.name ?? '',
      wpn1Atk: weaponSlots[0] != null ? weaponAttackBonus(weaponSlots[0]!) : '',
      wpn1Dmg: weaponSlots[0] != null ? weaponDamage(weaponSlots[0]!) : '',

      wpn2Name: weaponSlots[1]?.weapon.name ?? '',
      wpn2Atk: weaponSlots[1] != null ? weaponAttackBonus(weaponSlots[1]!) : '',
      wpn2Dmg: weaponSlots[1] != null ? weaponDamage(weaponSlots[1]!) : '',

      wpn3Name: weaponSlots[2]?.weapon.name ?? '',
      wpn3Atk: weaponSlots[2] != null ? weaponAttackBonus(weaponSlots[2]!) : '',
      wpn3Dmg: weaponSlots[2] != null ? weaponDamage(weaponSlots[2]!) : '',
      spellInfo: spellInfo.summary,
      equipment: equipLines.join('\n'),
      gp: invVM.gp,
      pp: invVM.pp,
      ep: invVM.ep,
      sp: invVM.sp,
      cp: invVM.cp,
      proficienciesAndLanguages: profLines.join('\n'),
      page1Features: page1Features,
      page2Features: page2Features,
      personalityTraits: personalityTraits,
      ideals: ideals,
      bonds: bonds,
      flaws: flaws,
      spellAbility: spellInfo.ability,
      spellAttackBonus: spellInfo.attackBonus,
      spellSaveDC: spellInfo.saveDc,
      spellsByLevel: spellsByLevel,
      slotCounts: slotCounts,
    );
  }

  static List<String> _buildEquipmentLines(
    CharacterInventoryViewModel invVM,
    List<WeaponEntry> weapons,
  ) {
    final lines = <String>[];

    if (invVM.backgroundEquipmentText.isNotEmpty) {
      lines.add(invVM.backgroundEquipmentText);
    }

    if (invVM.equippedArmor != null) {
      lines.add(
        '${invVM.equippedArmor!.name} (CA ${invVM.equippedArmor!.acString})',
      );
    }

    if (invVM.equippedShield != null) {
      lines.add(invVM.equippedShield!.name);
    }

    for (final entry in weapons) {
      lines.add(
        '${entry.weapon.name}${entry.quantity > 1 ? ' ×${entry.quantity}' : ''}',
      );
    }

    lines.addAll(invVM.tools);

    return lines;
  }

  static List<String> _buildProficiencyLines(
    CreateCharacterViewModel vm,
    Set<String> subclassSkills,
    Set<String> expertiseChoices,
  ) {
    final lines = <String>[];

    if (vm.armorProficiencies.isNotEmpty) {
      lines.add('Armor: ${vm.armorProficiencies.join(', ')}');
    }

    if (vm.weaponProficiencies.isNotEmpty) {
      lines.add('Weapons: ${vm.weaponProficiencies.join(', ')}');
    }

    if (vm.toolProficiencies.isNotEmpty) {
      lines.add('Tools: ${vm.toolProficiencies.join(', ')}');
    }

    if (subclassSkills.isNotEmpty) {
      lines.add(
        'Subclass Skills: ${subclassSkills.map(CharacterSheetTextUtils.titleCase).join(', ')}',
      );
    }

    if (expertiseChoices.isNotEmpty) {
      lines.add('Expertise: ${expertiseChoices.join(', ')}');
    }

    final languages = <String>{
      ...vm.languageVM.totalFixedLanguages,
      ...vm.languageVM.selectedRacialLanguages.where((l) => l.isNotEmpty),
      ...vm.languageVM.selectedBgLanguages.where((l) => l.isNotEmpty),
      ...vm.languageVM.featLanguages,
    };

    if (languages.isNotEmpty) {
      lines.add('Languages: ${languages.join(', ')}');
    }

    return lines;
  }

  static String _buildPage1Features(CreateCharacterViewModel vm) {
    return CharacterSheetTextUtils.cleanPdfText(vm.getCleanedRaceTraits());
  }

  static String _buildPage2Features({
  required CreateCharacterViewModel vm,
  required DetailClassViewModel? detailVM,
  required dynamic charClass,
}) {
  final sections = <String>[];

  final classSlug = (charClass?.slug ?? '')
      .toString()
      .trim()
      .toLowerCase();

  // ─────────────────────────────────────────────────────────────
  // Background
  // ─────────────────────────────────────────────────────────────

  final bgFeature = (vm.selectedBackground?['feature'] ?? '')
      .toString()
      .trim();

  final bgDesc = CharacterSheetTextUtils.cleanPdfText(
    vm.selectedBackground?['feature_desc'] ?? '',
  );

  if (bgFeature.isNotEmpty && bgDesc.isNotEmpty) {
    sections.add(
      'BACKGROUND: $bgFeature\n$bgDesc',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Class features desbloqueados
  // ─────────────────────────────────────────────────────────────

  if (charClass != null && detailVM != null) {
    final unlocked = detailVM.getUnlockedFeatures(
      charClass,
      vm.level,
    );

    if (unlocked.isNotEmpty) {
      final buffer = StringBuffer(
        'CLASS FEATURES - ${charClass.name} Lv${vm.level}\n',
      );

      /*
       * Warlock tiene dos encabezados llamados Eldritch Invocations:
       *
       * 1. La característica de nivel 2.
       * 2. El catálogo completo de invocaciones.
       *
       * Al encontrar el segundo, dejamos de imprimir el catálogo.
       */
      var eldritchInvocationSections = 0;

      for (final feature in unlocked) {
        final title = (feature['title'] ?? '')
            .toString()
            .trim();

        if (title.isEmpty) {
          continue;
        }

        final normalizedTitle = title.toLowerCase();

        if (classSlug == 'warlock') {
          if (normalizedTitle == 'eldritch invocations') {
            eldritchInvocationSections++;

            if (eldritchInvocationSections >= 2) {
              break;
            }
          }

          if (_shouldSkipWarlockFeature(
            normalizedTitle,
          )) {
            continue;
          }
        }

        final rawDescription = (feature['desc'] ?? '')
            .toString();

        final description = _compactClassFeatureForPdf(
          classSlug: classSlug,
          featureTitle: normalizedTitle,
          rawDescription: rawDescription,
        );

        if (description.isEmpty) {
          continue;
        }

        buffer
          ..writeln()
          ..writeln(title.toUpperCase())
          ..writeln(description);
      }

      final classFeaturesText = buffer.toString().trim();

      if (classFeaturesText.isNotEmpty) {
        sections.add(classFeaturesText);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Subclase
  // ─────────────────────────────────────────────────────────────

  final selectedArchetype = detailVM?.selectedArchetype;

  if (selectedArchetype != null) {
    /*
     * Se hace una copia para no modificar el arquetipo almacenado
     * dentro del ViewModel.
     */
    final sanitizedArchetype = Map<String, dynamic>.from(
      selectedArchetype,
    );

    final archetypeSlug = (
      selectedArchetype['slug'] ?? ''
    ).toString();

    final rawArchetypeDescription = (
      selectedArchetype['desc'] ?? ''
    ).toString();

    sanitizedArchetype['desc'] =
        PdfFeatureTextPolicy.sanitizeSubclassDescription(
      classSlug: classSlug,
      archetypeSlug: archetypeSlug,
      rawDescription: rawArchetypeDescription,
    );

    final subclassTraitsText =
        CharacterSheetTextUtils.buildSubclassTraitsText(
      sanitizedArchetype,
      vm.level,
    );

    if (subclassTraitsText.isNotEmpty) {
      sections.add(subclassTraitsText);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Fighting Style
  // ─────────────────────────────────────────────────────────────

  final fightingStyle = detailVM?.selectedFightingStyleName;

  if (fightingStyle != null &&
      fightingStyle.trim().isNotEmpty) {
    sections.add(
      'FIGHTING STYLE: ${fightingStyle.trim()}',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Feats
  // ─────────────────────────────────────────────────────────────

  vm.levelUpChoices.forEach((level, choice) {
    if (choice['type'] != 'feat') {
      return;
    }

    final featData = choice['data'];

    if (featData is! Map) {
      return;
    }

    final featName = (featData['name'] ?? '')
        .toString()
        .trim();

    final featDescription =
        CharacterSheetTextUtils.cleanPdfText(
      featData['desc'] ?? '',
    );

    if (featName.isEmpty) {
      return;
    }

    final section = StringBuffer(
      'FEAT (Lv$level): $featName',
    );

    if (featDescription.isNotEmpty) {
      section
        ..writeln()
        ..write(featDescription);
    }

    sections.add(section.toString());
  });

  // ─────────────────────────────────────────────────────────────
  // Dragonborn
  // ─────────────────────────────────────────────────────────────

  if (vm.dragonbornTraitsSummary.isNotEmpty) {
    sections.add(
      'DRACONIC ANCESTRY\n'
      '${vm.dragonbornTraitsSummary}',
    );
  }

  if (sections.isEmpty) {
    return 'No se encontraron rasgos de clase o '
        'trasfondo para este nivel.';
  }

  return sections.join(
    '\n\n──────────────────────────\n\n',
  );
}
  static String _compactClassFeatureForPdf({
  required String classSlug,
  required String featureTitle,
  required String rawDescription,
}) {
  final cleanDescription =
      CharacterSheetTextUtils.cleanPdfText(
    rawDescription,
  );

  if (cleanDescription.isEmpty) {
    return '';
  }

  if (classSlug != 'warlock') {
    return cleanDescription;
  }

  switch (featureTitle) {
    case 'eldritch invocations':
      return 'You learn special Eldritch Invocations according '
          'to your warlock level. Record only the invocations '
          'selected for this character.';

    case 'pact boon':
      return 'At 3rd level, your patron grants you one Pact Boon: '
          'Pact of the Chain, Pact of the Blade, or Pact of the '
          'Tome. Record only the boon selected for this character.';

    default:

      if (_containsWarlockInvocationCatalog(
        cleanDescription,
      )) {
        return 'Eldritch invocation catalog omitted from the '
            'character sheet. Consult the application for the '
            'available invocation descriptions.';
      }

      return cleanDescription;
  }
}

static bool _shouldSkipWarlockFeature(
  String normalizedTitle,
) {
  const skippedTitles = <String>{
    'pact of the chain',
    'pact of the blade',
    'pact of the tome',
    'your pact boon',
    'otherworldly patrons',
  };

  return skippedTitles.contains(normalizedTitle);
}

static bool _containsWarlockInvocationCatalog(
  String description,
) {
  final normalized = description.toLowerCase();
  var matches = 0;

  const invocationNames = <String>[
    'agonizing blast',
    'armor of shadows',
    'ascendant step',
    'beast speech',
    'beguiling influence',
    "devil's sight",
    'eldritch sight',
    'eldritch spear',
    'fiendish vigor',
    'mask of many faces',
    'repelling blast',
    'thirsting blade',
    'witch sight',
  ];

  for (final name in invocationNames) {
    if (normalized.contains(name)) {
      matches++;
    }

    if (matches >= 3) {
      return true;
    }
  }

  return false;
}


  static _SpellInfo _buildSpellInfo(
    CreateCharacterViewModel vm,
    int profBonus,
    SpellcastingSource? source,
  ) {
    if (source == null || source.ability.isEmpty) {
      return const _SpellInfo();
    }

    final ability = source.ability;
    final spellMod = vm.getModifier(ability);
    final attackBonus = spellMod + profBonus;
    final saveDc = 8 + profBonus + spellMod;

    return _SpellInfo(
      ability: ability,
      attackBonus: attackBonus,
      saveDc: saveDc,
      summary:
          'Spellcasting: $ability | Atk: ${CharacterSheetTextUtils.sign(attackBonus)} | DC: $saveDc',
    );
  }

  static Map<int, List<SpellModel>> _buildSpellsByLevel(
    CharacterSpellViewModel? spellVM,
  ) {
    final selectedSpells = spellVM?.getSelectedSpellModels() ?? [];
    final spellsByLevel = <int, List<SpellModel>>{};

    for (final spell in selectedSpells) {
      (spellsByLevel[spell.levelInt] ??= []).add(spell);
    }

    for (final list in spellsByLevel.values) {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return spellsByLevel;
  }

  static Map<int, int> _buildSlotCounts(
    CreateCharacterViewModel vm,
    CharacterSpellViewModel? spellVM,
    SpellcastingSource? source,
  ) {
    final slotCounts = <int, int>{};

    if (spellVM == null || source == null) {
      return slotCounts;
    }

    final info = spellVM.parseSpellcastingInfo(
      source.table,
      source.rulesSlug,
      vm.level,
    );

    if (info == null) {
      return slotCounts;
    }

    for (int i = 0; i < 9; i++) {
      if (info.slotsPerLevel[i] > 0) {
        slotCounts[i + 1] = info.slotsPerLevel[i];
      }
    }

    if (source.rulesSlug == 'warlock' && info.warlockSlots > 0) {
      slotCounts[info.warlockSlotLevel] = info.warlockSlots;
    }

    return slotCounts;
  }

}

class _SpellInfo {
  final String ability;
  final int attackBonus;
  final int saveDc;
  final String summary;

  const _SpellInfo({
    this.ability = '',
    this.attackBonus = 0,
    this.saveDc = 0,
    this.summary = '',
  });
}
