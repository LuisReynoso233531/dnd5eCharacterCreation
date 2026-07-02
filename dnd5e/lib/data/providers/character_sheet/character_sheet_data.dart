import '../../models/spell_model.dart';

class CharacterSheetData {
  final String characterName;
  final String classLevel;
  final String race;
  final String background;
  final String className;

  final String playerName;
  final String alignment;
  final String temporaryHp;

  final int str;
  final int dex;
  final int con;
  final int intel;
  final int wis;
  final int cha;

  final int strMod;
  final int dexMod;
  final int conMod;
  final int intMod;
  final int wisMod;
  final int chaMod;

  final int profBonus;
  final int ac;
  final int initiative;
  final int speed;
  final int hpMax;
  final int passivePerception;

  final String hitDice;

  final Map<String, bool> stProficiency;
  final Map<String, int> stValues;

  final Set<String> skillProficiencies;
  final Map<String, int> skillValues;

  final String wpn1Name;
  final String wpn1Atk;
  final String wpn1Dmg;
  final String wpn2Name;
  final String wpn2Atk;
  final String wpn2Dmg;
  final String wpn3Name;
  final String wpn3Atk;
  final String wpn3Dmg;

  final String spellInfo;
  final String equipment;

  final int gp;
  final int pp;
  final int ep;
  final int sp;
  final int cp;

  final String proficienciesAndLanguages;
  final String page1Features;
  final String page2Features;

  final String personalityTraits;
  final String ideals;
  final String bonds;
  final String flaws;

  final String spellAbility;
  final int spellAttackBonus;
  final int spellSaveDC;

  final Map<int, List<SpellModel>> spellsByLevel;
  final Map<int, int> slotCounts;

  const CharacterSheetData({
    required this.characterName,
    required this.classLevel,
    required this.race,
    required this.background,
    required this.className,
    required this.playerName,
    required this.alignment,
    required this.temporaryHp,
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
    required this.page1Features,
    required this.page2Features,
    required this.personalityTraits,
    required this.ideals,
    required this.bonds,
    required this.flaws,
    required this.spellAbility,
    required this.spellAttackBonus,
    required this.spellSaveDC,
    required this.spellsByLevel,
    required this.slotCounts,
  });
}
