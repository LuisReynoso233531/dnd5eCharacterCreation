import '../../models/spell_model.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../view_models/character/character_inventory_view_model.dart';
import '../../../view_models/character/character_spell_view_model.dart';
import '../../../view_models/character/character_detail_class_view_model.dart';
import '../../../view_models/character/character_subclass_view_model.dart';

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

    final strMod = vm.getModifier('Strength');
    final dexMod = vm.getModifier('Dexterity');
    final conMod = vm.getModifier('Constitution');
    final intMod = vm.getModifier('Intelligence');
    final wisMod = vm.getModifier('Wisdom');
    final chaMod = vm.getModifier('Charisma');

    final ac = invVM.calculateTotalAC(
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

    final allSkillProfs = <String>{
      ...vm.skillVM.classFixedSkills,
      ...vm.skillVM.bgFixedSkills,
      ...vm.skillVM.selectedClassSkills,
      ...vm.racialSkillProficiencies,
      ...subclassSkills,
    }.map((s) => s.toLowerCase()).toSet();

    int skillVal(String skill, String stat) {
      final mod = vm.getModifier(stat);

      return allSkillProfs.contains(skill.toLowerCase())
          ? mod + profBonus
          : mod;
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

    final passivePerception =
        10 + wisMod + (allSkillProfs.contains('perception') ? profBonus : 0);

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
    final profLines = _buildProficiencyLines(vm, subclassSkills);
    final page1Features = _buildPage1Features(vm);
    final page2Features = _buildPage2Features(
      vm: vm,
      detailVM: detailVM,
      charClass: charClass,
    );

    final spellInfo = _buildSpellInfo(vm, profBonus);
    final spellsByLevel = _buildSpellsByLevel(spellVM);
    final slotCounts = _buildSlotCounts(vm, spellVM);

    final manualHp = detailVM?.calculateTotalHP() ?? 0;
    final sheetMaxHp = manualHp > 0 ? manualHp : vm.maxHp;

    return CharacterSheetData(
      characterName: vm.name,
      classLevel: '${charClass?.name ?? ''} ${vm.level}',
      race: vm.selectedRace?['name'] ?? '',
      background: vm.selectedBackground?['name'] ?? '',
      className: charClass?.name ?? '',
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

    final bgFeature = vm.selectedBackground?['feature'] ?? '';
    final bgDesc = CharacterSheetTextUtils.cleanPdfText(
      vm.selectedBackground?['feature_desc'] ?? '',
    );

    if (bgFeature.isNotEmpty && bgDesc.isNotEmpty) {
      sections.add('BACKGROUND: $bgFeature\n$bgDesc');
    }

    if (charClass != null && detailVM != null) {
      final unlocked = detailVM.getUnlockedFeatures(charClass, vm.level);

      if (unlocked.isNotEmpty) {
        final buf = StringBuffer(
          'CLASS FEATURES - ${charClass.name} Lv${vm.level}\n',
        );

        for (final f in unlocked) {
          final title = (f['title'] ?? '').toString().toUpperCase();
          final desc = CharacterSheetTextUtils.cleanPdfText(f['desc'] ?? '');

          if (desc.isNotEmpty) {
            buf.writeln('\n$title\n$desc');
          }
        }

        sections.add(buf.toString().trim());
      }
    }

    final subclassTraitsText = CharacterSheetTextUtils.buildSubclassTraitsText(
      detailVM?.selectedArchetype,
      vm.level,
    );

    if (subclassTraitsText.isNotEmpty) {
      sections.add(subclassTraitsText);
    }

    final fightingStyle = detailVM?.selectedFightingStyleName;
    if (fightingStyle != null && fightingStyle.isNotEmpty) {
      sections.add('FIGHTING STYLE: $fightingStyle');
    }

    vm.levelUpChoices.forEach((lvl, choice) {
      if (choice['type'] == 'feat') {
        final featName = choice['data']['name'] ?? '';
        final featDesc = CharacterSheetTextUtils.cleanPdfText(
          choice['data']['desc'] ?? '',
        );

        if (featName.isNotEmpty) {
          sections.add('FEAT (Lv$lvl): $featName\n$featDesc');
        }
      }
    });

    if (vm.dragonbornTraitsSummary.isNotEmpty) {
      sections.add('DRACONIC ANCESTRY\n${vm.dragonbornTraitsSummary}');
    }

    if (sections.isEmpty) {
      return 'No se encontraron rasgos de clase o trasfondo para este nivel.';
    }

    return sections.join('\n\n──────────────────────────\n\n');
  }

  static _SpellInfo _buildSpellInfo(
    CreateCharacterViewModel vm,
    int profBonus,
  ) {
    final charClass = vm.selectedClass;

    if (charClass == null || charClass.spellcasting_ability.isEmpty) {
      return const _SpellInfo();
    }

    final ability = charClass.spellcasting_ability;
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
  ) {
    final slotCounts = <int, int>{};
    final charClass = vm.selectedClass;

    if (spellVM == null || charClass == null) {
      return slotCounts;
    }

    final info = spellVM.parseSpellcastingInfo(
      charClass.table,
      charClass.slug,
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

    if (charClass.slug == 'warlock' && info.warlockSlots > 0) {
      slotCounts[info.warlockSlotLevel] = info.warlockSlots;
    }

    return slotCounts;
  }

  static String _atkBonus(
    WeaponEntry entry,
    int strMod,
    int dexMod,
    int profBonus,
  ) {
    final statMod = _weaponStatMod(entry, strMod, dexMod);
    return CharacterSheetTextUtils.sign(statMod + profBonus);
  }

  static String _damageText(WeaponEntry entry, int strMod, int dexMod) {
    final statMod = _weaponStatMod(entry, strMod, dexMod);
    final dice = entry.weapon.damageDice.isNotEmpty
        ? entry.weapon.damageDice
        : '-';
    final mod = statMod != 0 ? ' ${CharacterSheetTextUtils.sign(statMod)}' : '';

    return '$dice$mod ${entry.weapon.damageType}'.trim();
  }

  static int _weaponStatMod(WeaponEntry entry, int strMod, int dexMod) {
    final isFinesse = entry.weapon.properties.any(
      (p) => p.toLowerCase().contains('finesse'),
    );

    if (isFinesse) {
      return strMod > dexMod ? strMod : dexMod;
    }

    return entry.weapon.isRanged ? dexMod : strMod;
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
