import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharacterSheetService
// Fills the official D&D 5e fillable PDF using syncfusion_flutter_pdf.
// Works on Android, iOS, macOS, Windows, Linux — no Python required.
// ─────────────────────────────────────────────────────────────────────────────

class CharacterSheetService {
  // ── 1. Build snapshot of all character data ──────────────────────────────
  static CharacterSheetData buildData({
    required CreateCharacterViewModel vm,
    CharacterInventoryViewModel? invVM,
    CharacterSpellViewModel? spellVM,
  }) {
    final profBonus = CreateCharacterViewModel.proficiencyBonus(vm.level);

    // ── Basic info ───────────────────────────────────────────────────────
    final name = vm.name;
    final className = vm.selectedClass?.name ?? '';
    final level = vm.level;
    final race = vm.selectedRace?['name'] ?? '';
    final background = vm.selectedBackground?['name'] ?? '';

    // ── Core stats ───────────────────────────────────────────────────────
    final str   = vm.getTotalStat('Strength');
    final dex   = vm.getTotalStat('Dexterity');
    final con   = vm.getTotalStat('Constitution');
    final intel = vm.getTotalStat('Intelligence');
    final wis   = vm.getTotalStat('Wisdom');
    final cha   = vm.getTotalStat('Charisma');

    // ── Saving throw proficiencies ───────────────────────────────────────
    final stText =
        (vm.selectedClass?.prof_saving_throws ?? '').toLowerCase();
    final stProfs = <String, bool>{
      'strength':     stText.contains('strength'),
      'dexterity':    stText.contains('dexterity'),
      'constitution': stText.contains('constitution'),
      'intelligence': stText.contains('intelligence'),
      'wisdom':       stText.contains('wisdom'),
      'charisma':     stText.contains('charisma'),
    };

    // ── Skill proficiency set ────────────────────────────────────────────
    final allSkillProfs = <String>{
      ...vm.skillVM.classFixedSkills,
      ...vm.skillVM.bgFixedSkills,
      ...vm.skillVM.selectedClassSkills,
      ...vm.racialSkillProficiencies,
    }.map((s) => s.toLowerCase()).toSet();

    // ── Skill value helper ───────────────────────────────────────────────
    int skillVal(String skill, String stat) {
      final mod = vm.getModifier(stat);
      return allSkillProfs.contains(skill.toLowerCase())
          ? mod + profBonus
          : mod;
    }

    final skillValues = <String, int>{
      'acrobatics':    skillVal('Acrobatics',    'Dexterity'),
      'animal handling': skillVal('Animal Handling', 'Wisdom'),
      'arcana':        skillVal('Arcana',        'Intelligence'),
      'athletics':     skillVal('Athletics',     'Strength'),
      'deception':     skillVal('Deception',     'Charisma'),
      'history':       skillVal('History',       'Intelligence'),
      'insight':       skillVal('Insight',       'Wisdom'),
      'intimidation':  skillVal('Intimidation',  'Charisma'),
      'investigation': skillVal('Investigation', 'Intelligence'),
      'medicine':      skillVal('Medicine',      'Wisdom'),
      'nature':        skillVal('Nature',        'Intelligence'),
      'perception':    skillVal('Perception',    'Wisdom'),
      'performance':   skillVal('Performance',   'Charisma'),
      'persuasion':    skillVal('Persuasion',    'Charisma'),
      'religion':      skillVal('Religion',      'Intelligence'),
      'sleight of hand': skillVal('Sleight of Hand', 'Dexterity'),
      'stealth':       skillVal('Stealth',       'Dexterity'),
      'survival':      skillVal('Survival',      'Wisdom'),
    };

    // ── Saving throw values ──────────────────────────────────────────────
    final stValues = <String, int>{
      'strength':     vm.getModifier('Strength')     + (stProfs['strength']!     ? profBonus : 0),
      'dexterity':    vm.getModifier('Dexterity')    + (stProfs['dexterity']!    ? profBonus : 0),
      'constitution': vm.getModifier('Constitution') + (stProfs['constitution']! ? profBonus : 0),
      'intelligence': vm.getModifier('Intelligence') + (stProfs['intelligence']! ? profBonus : 0),
      'wisdom':       vm.getModifier('Wisdom')       + (stProfs['wisdom']!       ? profBonus : 0),
      'charisma':     vm.getModifier('Charisma')     + (stProfs['charisma']!     ? profBonus : 0),
    };

    // ── Passive Perception ───────────────────────────────────────────────
    final passivePerception = 10 +
        vm.getModifier('Wisdom') +
        (allSkillProfs.contains('perception') ? profBonus : 0);

    // ── Combat ───────────────────────────────────────────────────────────
    final ac = invVM?.calculateTotalAC(
          dexMod: vm.getModifier('Dexterity'),
          conMod: vm.getModifier('Constitution'),
          wisMod: vm.getModifier('Wisdom'),
        ) ??
        (10 + vm.getModifier('Dexterity'));

    // ── Weapons (first 3) ────────────────────────────────────────────────
    final weapons = invVM?.weaponEntries ?? [];

    String atkBonus(WeaponEntry e) {
      final isFinesse =
          e.weapon.properties.any((p) => p.toLowerCase().contains('finesse'));
      final isRanged = e.weapon.isRanged;
      int statMod;
      if (isFinesse) {
        statMod = [vm.getModifier('Strength'), vm.getModifier('Dexterity')]
            .reduce((a, b) => a > b ? a : b);
      } else if (isRanged) {
        statMod = vm.getModifier('Dexterity');
      } else {
        statMod = vm.getModifier('Strength');
      }
      final bonus = statMod + profBonus;
      return _sign(bonus);
    }

    String dmgStr(WeaponEntry e) {
      final dice = e.weapon.damageDice;
      final isFinesse =
          e.weapon.properties.any((p) => p.toLowerCase().contains('finesse'));
      final isRanged = e.weapon.isRanged;
      int statMod;
      if (isFinesse) {
        statMod = [vm.getModifier('Strength'), vm.getModifier('Dexterity')]
            .reduce((a, b) => a > b ? a : b);
      } else if (isRanged) {
        statMod = vm.getModifier('Dexterity');
      } else {
        statMod = vm.getModifier('Strength');
      }
      final modStr = statMod != 0 ? ' ${_sign(statMod)}' : '';
      return '$dice$modStr ${e.weapon.damageType}';
    }

    final wpn = List.generate(3, (i) => i < weapons.length ? weapons[i] : null);

    // ── Equipment text ────────────────────────────────────────────────────
    final equipLines = <String>[];
    if (invVM?.backgroundEquipmentText.isNotEmpty == true) {
      equipLines.add(invVM!.backgroundEquipmentText);
    }
    if (invVM?.equippedArmor != null) equipLines.add(invVM!.equippedArmor!.name);
    if (invVM?.equippedShield != null) equipLines.add(invVM!.equippedShield!.name);
    for (final e in (invVM?.weaponEntries ?? [])) {
      equipLines.add('${e.weapon.name}${e.quantity > 1 ? ' ×${e.quantity}' : ''}');
    }
    equipLines.addAll(invVM?.tools ?? []);

    // ── Money ─────────────────────────────────────────────────────────────
    final gp = invVM?.gp ?? 0;
    final pp = invVM?.pp ?? 0;
    final ep = invVM?.ep ?? 0;
    final sp = invVM?.sp ?? 0;
    final cp = invVM?.cp ?? 0;

    // ── Proficiencies & Languages ─────────────────────────────────────────
    final profLines = <String>[];
    if (vm.armorProficiencies.isNotEmpty) {
      profLines.add('Armor: ${vm.armorProficiencies.join(', ')}');
    }
    if (vm.weaponProficiencies.isNotEmpty) {
      profLines.add('Weapons: ${vm.weaponProficiencies.join(', ')}');
    }
    if (vm.toolProficiencies.isNotEmpty) {
      profLines.add('Tools: ${vm.toolProficiencies.join(', ')}');
    }
    final allLanguages = {
      ...vm.languageVM.totalFixedLanguages,
      ...vm.languageVM.selectedRacialLanguages.where((l) => l.isNotEmpty),
      ...vm.languageVM.selectedBgLanguages.where((l) => l.isNotEmpty),
      ...vm.languageVM.featLanguages,
    };
    if (allLanguages.isNotEmpty) {
      profLines.add('Languages: ${allLanguages.join(', ')}');
    }

    // ── Features & Traits ─────────────────────────────────────────────────
    final featLines = <String>[];
    final raceTraits = vm.getCleanedRaceTraits()
        .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    if (raceTraits.isNotEmpty) featLines.add(raceTraits);

    final bgFeature    = vm.selectedBackground?['feature'] ?? '';
    final bgFeatureDesc = (vm.selectedBackground?['feature_desc'] ?? '')
        .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
        .trim();
    if (bgFeature.isNotEmpty) featLines.add('$bgFeature\n$bgFeatureDesc');

    vm.levelUpChoices.forEach((lvl, choice) {
      if (choice['type'] == 'feat') {
        final featName = choice['data']['name'] ?? '';
        final featDesc = (choice['data']['desc'] ?? '')
            .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
            .trim();
        if (featName.isNotEmpty) {
          featLines.add('$featName (Level $lvl Feat)\n$featDesc');
        }
      }
    });

    if (vm.dragonbornTraitsSummary.isNotEmpty) {
      featLines.add(vm.dragonbornTraitsSummary);
    }

    // ── Spellcasting info ─────────────────────────────────────────────────
    String spellInfo = '';
    final spellAbility = vm.selectedClass?.spellcasting_ability ?? '';
    if (spellAbility.isNotEmpty) {
      final spellMod = vm.getModifier(spellAbility);
      final spellAtk = spellMod + profBonus;
      final saveDC = 8 + profBonus + spellMod;
      spellInfo =
          'Spellcasting: $spellAbility | Atk: ${_sign(spellAtk)} | DC: $saveDC';
    }

    return CharacterSheetData(
      characterName: name,
      classLevel: '$className $level',
      race: race,
      background: background,
      str: str, dex: dex, con: con,
      intel: intel, wis: wis, cha: cha,
      strMod: vm.getModifier('Strength'),
      dexMod: vm.getModifier('Dexterity'),
      conMod: vm.getModifier('Constitution'),
      intMod: vm.getModifier('Intelligence'),
      wisMod: vm.getModifier('Wisdom'),
      chaMod: vm.getModifier('Charisma'),
      profBonus: profBonus,
      ac: ac,
      initiative: vm.getModifier('Dexterity'),
      speed: vm.speed,
      hpMax: vm.maxHp,
      hitDice: '${vm.level}d${vm.selectedClass?.hit_dice ?? '8'}',
      passivePerception: passivePerception,
      stProficiency: stProfs,
      stValues: stValues,
      skillProficiencies: allSkillProfs,
      skillValues: skillValues,
      wpn1Name: wpn[0]?.weapon.name ?? '',
      wpn1Atk: wpn[0] != null ? atkBonus(wpn[0]!) : '',
      wpn1Dmg: wpn[0] != null ? dmgStr(wpn[0]!) : '',
      wpn2Name: wpn[1]?.weapon.name ?? '',
      wpn2Atk: wpn[1] != null ? atkBonus(wpn[1]!) : '',
      wpn2Dmg: wpn[1] != null ? dmgStr(wpn[1]!) : '',
      wpn3Name: wpn[2]?.weapon.name ?? '',
      wpn3Atk: wpn[2] != null ? atkBonus(wpn[2]!) : '',
      wpn3Dmg: wpn[2] != null ? dmgStr(wpn[2]!) : '',
      spellInfo: spellInfo,
      equipment: equipLines.join('\n'),
      gp: gp, pp: pp, ep: ep, sp: sp, cp: cp,
      proficienciesAndLanguages: profLines.join('\n'),
      featuresAndTraits: featLines.join('\n\n---\n\n'),
      personalityTraits: '',
      ideals: '',
      bonds: '',
      flaws: '',
    );
  }

  // ── 2. Fill the PDF using syncfusion_flutter_pdf ─────────────────────────
  static Future<String> generatePdf({
    required CharacterSheetData d,
    required String blankPdfAssetPath,
  }) async {
    // Load blank PDF from assets
    final assetBytes = await rootBundle.load(blankPdfAssetPath);
    final pdfBytes = assetBytes.buffer.asUint8List();

    // Open with Syncfusion
    final document = PdfDocument(inputBytes: pdfBytes);
    final form = document.form;
    // Allow generating a flat (non-editable) PDF — set to false to keep fields editable
    form.setDefaultAppearance(false);

    void setText(String fieldName, String value) {
      try {
        for (int i = 0; i < form.fields.count; i++) {
          final field = form.fields[i];
          if (field.name == fieldName) {
            if (field is PdfTextBoxField) {
              field.text = value;
            }
            break; // Detenemos la búsqueda al encontrarlo
          }
        }
      } catch (_) {}
    }

    // Helper to set a checkbox by name
    void setCheck(String fieldName, bool checked) {
      try {
        for (int i = 0; i < form.fields.count; i++) {
          final field = form.fields[i];
          if (field.name == fieldName) {
            if (field is PdfCheckBoxField) {
              field.isChecked = checked;
            }
            break; // Detenemos la búsqueda al encontrarlo
          }
        }
      } catch (_) {}
    }

    // ── Header ──────────────────────────────────────────────────────────
    setText('CharacterName', d.characterName);
    setText('ClassLevel',    d.classLevel);
    setText('Race ',         d.race);
    setText('Background',    d.background);
    setText('Alignment',     '');
    setText('XP',            '');
    setText('PlayerName',    '');

    // ── Core stats ───────────────────────────────────────────────────────
    setText('STR',    '${d.str}');
    setText('DEX',    '${d.dex}');
    setText('CON',    '${d.con}');
    setText('INT',    '${d.intel}');
    setText('WIS',    '${d.wis}');
    setText('CHA',    '${d.cha}');
    setText('STRmod', _sign(d.strMod));
    setText('DEXmod ', _sign(d.dexMod));
    setText('CONmod', _sign(d.conMod));
    setText('INTmod', _sign(d.intMod));
    setText('WISmod', _sign(d.wisMod));
    setText('CHamod', _sign(d.chaMod));

    // ── Combat ───────────────────────────────────────────────────────────
    setText('ProfBonus',  _sign(d.profBonus));
    setText('AC',         '${d.ac}');
    setText('Initiative', _sign(d.initiative));
    setText('Speed',      '${d.speed}');
    setText('HPMax',      '${d.hpMax}');
    setText('HPCurrent',  '${d.hpMax}');
    setText('HPTemp',     '');
    setText('HD',         d.hitDice);
    setText('HDTotal',    d.hitDice);
    setText('Passive',    '${d.passivePerception}');

    // ── Saving throws ─────────────────────────────────────────────────────
    setText('ST Strength',     _sign(d.stValues['strength']!));
    setText('ST Dexterity',    _sign(d.stValues['dexterity']!));
    setText('ST Constitution', _sign(d.stValues['constitution']!));
    setText('ST Intelligence', _sign(d.stValues['intelligence']!));
    setText('ST Wisdom',       _sign(d.stValues['wisdom']!));
    setText('ST Charisma',     _sign(d.stValues['charisma']!));
    // Proficiency checkboxes (Check Box 12–17 = ST Str→Cha)
    setCheck('Check Box 12', d.stProficiency['strength']!);
    setCheck('Check Box 13', d.stProficiency['dexterity']!);
    setCheck('Check Box 14', d.stProficiency['constitution']!);
    setCheck('Check Box 15', d.stProficiency['intelligence']!);
    setCheck('Check Box 16', d.stProficiency['wisdom']!);
    setCheck('Check Box 17', d.stProficiency['charisma']!);

    // ── Skills ────────────────────────────────────────────────────────────
    final sv = d.skillValues;
    final sp = d.skillProficiencies;

    setText('Acrobatics',     _sign(sv['acrobatics']!));
    setText('Animal',         _sign(sv['animal handling']!));
    setText('Arcana',         _sign(sv['arcana']!));
    setText('Athletics',      _sign(sv['athletics']!));
    setText('Deception ',     _sign(sv['deception']!));
    setText('History ',       _sign(sv['history']!));
    setText('Insight',        _sign(sv['insight']!));
    setText('Intimidation',   _sign(sv['intimidation']!));
    setText('Investigation ', _sign(sv['investigation']!));
    setText('Medicine',       _sign(sv['medicine']!));
    setText('Nature',         _sign(sv['nature']!));
    setText('Perception ',    _sign(sv['perception']!));
    setText('Performance',    _sign(sv['performance']!));
    setText('Persuasion',     _sign(sv['persuasion']!));
    setText('Religion',       _sign(sv['religion']!));
    setText('SleightofHand',  _sign(sv['sleight of hand']!));
    setText('Stealth ',       _sign(sv['stealth']!));
    setText('Survival',       _sign(sv['survival']!));

    // Skill proficiency checkboxes (Check Box 18–35 = Acrobatics→Survival)
    setCheck('Check Box 18', sp.contains('acrobatics'));
    setCheck('Check Box 19', sp.contains('animal handling'));
    setCheck('Check Box 20', sp.contains('arcana'));
    setCheck('Check Box 21', sp.contains('athletics'));
    setCheck('Check Box 22', sp.contains('deception'));
    setCheck('Check Box 23', sp.contains('history'));
    setCheck('Check Box 24', sp.contains('insight'));
    setCheck('Check Box 25', sp.contains('intimidation'));
    setCheck('Check Box 26', sp.contains('investigation'));
    setCheck('Check Box 27', sp.contains('medicine'));
    setCheck('Check Box 28', sp.contains('nature'));
    setCheck('Check Box 29', sp.contains('perception'));
    setCheck('Check Box 30', sp.contains('performance'));
    setCheck('Check Box 31', sp.contains('persuasion'));
    setCheck('Check Box 32', sp.contains('religion'));
    setCheck('Check Box 33', sp.contains('sleight of hand'));
    setCheck('Check Box 34', sp.contains('stealth'));
    setCheck('Check Box 35', sp.contains('survival'));

    // ── Weapons ───────────────────────────────────────────────────────────
    setText('Wpn Name',       d.wpn1Name);
    setText('Wpn1 AtkBonus',  d.wpn1Atk);
    setText('Wpn1 Damage',    d.wpn1Dmg);
    setText('Wpn Name 2',     d.wpn2Name);
    setText('Wpn2 AtkBonus ', d.wpn2Atk);
    setText('Wpn2 Damage ',   d.wpn2Dmg);
    setText('Wpn Name 3',     d.wpn3Name);
    setText('Wpn3 AtkBonus  ', d.wpn3Atk);
    setText('Wpn3 Damage ',   d.wpn3Dmg);
    setText('AttacksSpellcasting', d.spellInfo);

    // ── Equipment ─────────────────────────────────────────────────────────
    setText('Equipment', d.equipment);

    // ── Money ─────────────────────────────────────────────────────────────
    setText('GP', '${d.gp}');
    setText('PP', '${d.pp}');
    setText('EP', '${d.ep}');
    setText('SP', '${d.sp}');
    setText('CP', '${d.cp}');

    // ── Text sections ─────────────────────────────────────────────────────
    setText('ProficienciesLang',   d.proficienciesAndLanguages);
    setText('Features and Traits', d.featuresAndTraits);
    setText('PersonalityTraits ',  d.personalityTraits);
    setText('Ideals',              d.ideals);
    setText('Bonds',               d.bonds);
    setText('Flaws',               d.flaws);

    // ── Save to temp file ─────────────────────────────────────────────────
    final List<int> savedBytes = await document.save();
    document.dispose();

    final tempDir = await getTemporaryDirectory();
    final safeFileName = d.characterName.isEmpty
        ? 'character'
        : d.characterName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final outPath = '${tempDir.path}/${safeFileName}_sheet.pdf';

    final outFile = File(outPath);
    await outFile.writeAsBytes(savedBytes, flush: true);

    return outPath;
  }

  static String _sign(int n) => n >= 0 ? '+$n' : '$n';
}

// ─── Data model ───────────────────────────────────────────────────────────────

class CharacterSheetData {
  final String characterName, classLevel, race, background;
  final int str, dex, con, intel, wis, cha;
  final int strMod, dexMod, conMod, intMod, wisMod, chaMod;
  final int profBonus, ac, initiative, speed, hpMax, passivePerception;
  final String hitDice;
  final Map<String, bool> stProficiency;
  final Map<String, int> stValues;
  final Set<String> skillProficiencies;
  final Map<String, int> skillValues;
  final String wpn1Name, wpn1Atk, wpn1Dmg;
  final String wpn2Name, wpn2Atk, wpn2Dmg;
  final String wpn3Name, wpn3Atk, wpn3Dmg;
  final String spellInfo, equipment;
  final int gp, pp, ep, sp, cp;
  final String proficienciesAndLanguages, featuresAndTraits;
  final String personalityTraits, ideals, bonds, flaws;

  const CharacterSheetData({
    required this.characterName,
    required this.classLevel,
    required this.race,
    required this.background,
    required this.str,
    required this.dex,
    required this.con,
    required this.intel,
    required this.wis,
    required this.cha,
    required this.strMod,
    required this.dexMod,
    required this.conMod,
    required this.intMod,
    required this.wisMod,
    required this.chaMod,
    required this.profBonus,
    required this.ac,
    required this.initiative,
    required this.speed,
    required this.hpMax,
    required this.passivePerception,
    required this.hitDice,
    required this.stProficiency,
    required this.stValues,
    required this.skillProficiencies,
    required this.skillValues,
    required this.wpn1Name,
    required this.wpn1Atk,
    required this.wpn1Dmg,
    required this.wpn2Name,
    required this.wpn2Atk,
    required this.wpn2Dmg,
    required this.wpn3Name,
    required this.wpn3Atk,
    required this.wpn3Dmg,
    required this.spellInfo,
    required this.equipment,
    required this.gp,
    required this.pp,
    required this.ep,
    required this.sp,
    required this.cp,
    required this.proficienciesAndLanguages,
    required this.featuresAndTraits,
    required this.personalityTraits,
    required this.ideals,
    required this.bonds,
    required this.flaws,
  });
}