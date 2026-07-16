import 'dart:io';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../character_sheet_storage.dart';
import 'character_sheet_constants.dart';
import 'character_sheet_data.dart';
import 'character_sheet_text_utils.dart';
import 'pdf_field_writer.dart';

class CharacterSheetPdfGenerator {
  static Future<String> generate({
    required CharacterSheetData d,
    required String blankPdfAssetPath,
  }) async {
    final assetBytes = await rootBundle.load(blankPdfAssetPath);
    final document = PdfDocument(inputBytes: assetBytes.buffer.asUint8List());
    final form = document.form;

    form.setDefaultAppearance(false);

    final writer = PdfFieldWriter(form);

    _writePage1(writer, d);
    _writePage2(writer, d);
    _writePage3(writer, d);

    form.flattenAllFields();

    final bytes = await document.save();
    document.dispose();
    final outPath = await CharacterSheetStorage.createPdfPath(d.characterName);

    await File(outPath).writeAsBytes(bytes, flush: true);

    return outPath;
  }

  static void _writePage1(PdfFieldWriter writer, CharacterSheetData d) {
    final nameFontSize = d.characterName.length > 22 ? 8.0 : 10.0;

    writer
      ..setText('CharacterName', d.characterName, fontSize: nameFontSize)
      ..setText('ClassLevel', d.classLevel)
      ..setText('Race', d.race)
      ..setText('Background', d.background)
      ..setText('PlayerName', d.playerName)
      ..setText('Alignment', d.alignment)
      ..setText('XP', '')
      ..setText('STR', '${d.str}')
      ..setText('STRmod', CharacterSheetTextUtils.sign(d.strMod))
      ..setText('DEX', '${d.dex}')
      ..setText('DEXmod', CharacterSheetTextUtils.sign(d.dexMod))
      ..setText('CON', '${d.con}')
      ..setText('CONmod', CharacterSheetTextUtils.sign(d.conMod))
      ..setText('INT', '${d.intel}')
      ..setText('INTmod', CharacterSheetTextUtils.sign(d.intMod))
      ..setText('WIS', '${d.wis}')
      ..setText('WISmod', CharacterSheetTextUtils.sign(d.wisMod))
      ..setText('CHA', '${d.cha}')
      ..setText('CHamod', CharacterSheetTextUtils.sign(d.chaMod))
      ..setText('ProfBonus', CharacterSheetTextUtils.sign(d.profBonus))
      ..setText('AC', '${d.ac}')
      ..setText('Initiative', CharacterSheetTextUtils.sign(d.initiative))
      ..setText('Speed', '${d.speed}')
      ..setText('HPMax', '${d.hpMax}')
      ..setText('HPCurrent', '${d.hpMax}')
      ..setText('HPTemp', d.temporaryHp, fontSize: 12)
      ..setText('HD', d.hitDice)
      ..setText('HDTotal', d.hitDice)
      ..setText('Passive', '${d.passivePerception}');

    _writeSavingThrows(writer, d);
    _writeSkills(writer, d);
    _writeWeaponsAndEquipment(writer, d);

    writer
      ..setText(
        'ProficienciesLang',
        d.proficienciesAndLanguages,
        multiline: true,
        fontSize: 5.0,
      )
      ..setText(
        'Features and Traits',
        d.page1Features,
        multiline: true,
        fontSize: 4.5,
      )
      ..setText(
        'PersonalityTraits',
        d.personalityTraits,
        multiline: true,
        fontSize: 7,
      )
      ..setText('Ideals', d.ideals, multiline: true, fontSize: 7)
      ..setText('Bonds', d.bonds, multiline: true, fontSize: 7)
      ..setText('Flaws', d.flaws, multiline: true, fontSize: 7);
  }

  static void _writeSavingThrows(PdfFieldWriter writer, CharacterSheetData d) {
    writer
      ..setText(
        'ST Strength',
        CharacterSheetTextUtils.sign(d.stValues['strength']!),
      )
      ..setText(
        'ST Dexterity',
        CharacterSheetTextUtils.sign(d.stValues['dexterity']!),
      )
      ..setText(
        'ST Constitution',
        CharacterSheetTextUtils.sign(d.stValues['constitution']!),
      )
      ..setText(
        'ST Intelligence',
        CharacterSheetTextUtils.sign(d.stValues['intelligence']!),
      )
      ..setText(
        'ST Wisdom',
        CharacterSheetTextUtils.sign(d.stValues['wisdom']!),
      )
      ..setText(
        'ST Charisma',
        CharacterSheetTextUtils.sign(d.stValues['charisma']!),
      );

    final savingThrowCheckboxes = <String, String>{
      'strength': 'Check Box 11',
      'dexterity': 'Check Box 18',
      'constitution': 'Check Box 19',
      'intelligence': 'Check Box 20',
      'wisdom': 'Check Box 21',
      'charisma': 'Check Box 22',
    };

    for (final entry in savingThrowCheckboxes.entries) {
      writer.setCheckbox(entry.value, d.stProficiency[entry.key] ?? false);
    }
  }

  static void _writeSkills(PdfFieldWriter writer, CharacterSheetData d) {
    final sv = d.skillValues;
    final sp = d.skillProficiencies;

    writer
      ..setText('Acrobatics', CharacterSheetTextUtils.sign(sv['acrobatics']!))
      ..setText('Animal', CharacterSheetTextUtils.sign(sv['animal handling']!))
      ..setText('Arcana', CharacterSheetTextUtils.sign(sv['arcana']!))
      ..setText('Athletics', CharacterSheetTextUtils.sign(sv['athletics']!))
      ..setText('Deception', CharacterSheetTextUtils.sign(sv['deception']!))
      ..setText('History', CharacterSheetTextUtils.sign(sv['history']!))
      ..setText('Insight', CharacterSheetTextUtils.sign(sv['insight']!))
      ..setText(
        'Intimidation',
        CharacterSheetTextUtils.sign(sv['intimidation']!),
      )
      ..setText(
        'Investigation',
        CharacterSheetTextUtils.sign(sv['investigation']!),
      )
      ..setText('Medicine', CharacterSheetTextUtils.sign(sv['medicine']!))
      ..setText('Nature', CharacterSheetTextUtils.sign(sv['nature']!))
      ..setText('Perception', CharacterSheetTextUtils.sign(sv['perception']!))
      ..setText('Performance', CharacterSheetTextUtils.sign(sv['performance']!))
      ..setText('Persuasion', CharacterSheetTextUtils.sign(sv['persuasion']!))
      ..setText('Religion', CharacterSheetTextUtils.sign(sv['religion']!))
      ..setText(
        'SleightofHand',
        CharacterSheetTextUtils.sign(sv['sleight of hand']!),
      )
      ..setText('Stealth', CharacterSheetTextUtils.sign(sv['stealth']!))
      ..setText('Survival', CharacterSheetTextUtils.sign(sv['survival']!));

    final skillCheckboxes = <String, String>{
      'acrobatics': 'Check Box 23',
      'animal handling': 'Check Box 24',
      'arcana': 'Check Box 25',
      'athletics': 'Check Box 26',
      'deception': 'Check Box 27',
      'history': 'Check Box 28',
      'insight': 'Check Box 29',
      'intimidation': 'Check Box 30',
      'investigation': 'Check Box 31',
      'medicine': 'Check Box 32',
      'nature': 'Check Box 33',
      'perception': 'Check Box 34',
      'performance': 'Check Box 35',
      'persuasion': 'Check Box 36',
      'religion': 'Check Box 37',
      'sleight of hand': 'Check Box 38',
      'stealth': 'Check Box 39',
      'survival': 'Check Box 40',
    };

    for (final entry in skillCheckboxes.entries) {
      writer.setCheckbox(entry.value, sp.contains(entry.key));
    }
  }

  static void _writeWeaponsAndEquipment(
    PdfFieldWriter writer,
    CharacterSheetData d,
  ) {
    writer
      ..setText('Wpn Name', d.wpn1Name, fontSize: 7.2)
      ..setText('Wpn1 AtkBonus', d.wpn1Atk, fontSize: 7.2)
      ..setText('Wpn1 Damage', d.wpn1Dmg, fontSize: 7.2)
      ..setText('Wpn Name 2', d.wpn2Name, fontSize: 7.2)
      ..setText('Wpn2 AtkBonus', d.wpn2Atk, fontSize: 7.2)
      ..setText('Wpn2 Damage', d.wpn2Dmg, fontSize: 7.2)
      ..setText('Wpn Name 3', d.wpn3Name, fontSize: 7.2)
      ..setText('Wpn3 AtkBonus', d.wpn3Atk)
      ..setText('Wpn3 Damage', d.wpn3Dmg)
      ..setText(
        'AttacksSpellcasting',
        d.spellInfo,
        multiline: true,
        fontSize: 7,
      )
      ..setText('Equipment', d.equipment, multiline: true, fontSize: 5.0)
      ..setText('GP', '${d.gp}')
      ..setText('PP', '${d.pp}')
      ..setText('EP', '${d.ep}')
      ..setText('SP', '${d.sp}')
      ..setText('CP', '${d.cp}');
  }

  static void _writePage2(
  PdfFieldWriter writer,
  CharacterSheetData d,
) {
  final nameFontSize = d.characterName.length > 22
      ? 8.0
      : 10.0;

  writer.setText(
    'CharacterName 2',
    d.characterName,
    fontSize: nameFontSize,
  );

  final flowText = _featuresFlowText(d);
  String remaining = flowText;

  /*
   * Conserva inicialmente 4.5.
   * Solo reduce el tamaño cuando el contenido completo no cabe.
   *
   * Cada intento sobrescribe los campos anteriores.
   */
  for (final fontSize in const [
    4.5,
    4.2,
    3.9,
    3.6,
    3.4,
  ]) {
    remaining = writer.fillTextAcrossFields(
      text: flowText,
      fieldNames: const [
        'Features and Traits',
        'Allies',
        'Backstory',
        'Feat+Traits',
        'Treasure',
      ],
      fontSize: fontSize,
      reservedBottomLinesByField: const {
        'Features and Traits': 2,
        'Allies': 2,
        'Backstory': 2,
        'Feat+Traits': 2,
        'Treasure': 4,
      },
    );

    if (remaining.isEmpty) {
      break;
    }
  }

  if (remaining.isNotEmpty) {
    print(
      'PDF traits text still did not fit. '
      'Remaining chars: ${remaining.length}',
    );
  }
}

  static void _writePage3(PdfFieldWriter writer, CharacterSheetData d) {
    if (d.spellAbility.isNotEmpty) {
      writer
        ..setText('Spellcasting Class 2', d.className)
        ..setText('SpellcastingAbility 2', d.spellAbility)
        ..setText('SpellSaveDC  2', '${d.spellSaveDC}')
        ..setText(
          'SpellAtkBonus 2',
          CharacterSheetTextUtils.sign(d.spellAttackBonus),
        );
    }

    d.spellsByLevel.forEach((level, spells) {
      final fieldNames = spellFieldNamesByLevel[level];
      if (fieldNames == null) return;

      for (int i = 0; i < spells.length && i < fieldNames.length; i++) {
        final spell = spells[i];

        final badges = [
          if (spell.concentration) '(C)',
          if (spell.ritual) '(R)',
        ].join('');

        writer.setText(
          fieldNames[i],
          badges.isNotEmpty ? '${spell.name} $badges' : spell.name,
        );
      }
    });

    d.slotCounts.forEach((level, count) {
      final totalField = slotTotalFields[level];
      final remainingField = slotRemainingFields[level];

      if (totalField != null) {
        writer.setText(totalField, '$count');
      }

      if (remainingField != null) {
        writer.setText(remainingField, '$count');
      }
    });
  }

  static String _featuresFlowText(CharacterSheetData d) {
    final parts = <String>[
      if (d.page1Features.trim().isNotEmpty)
        'RACE FEATURES\n${d.page1Features.trim()}',
      if (d.page2Features.trim().isNotEmpty) d.page2Features.trim(),
    ];

    return parts.join('\n\n──────────────────────────\n\n');
  }
}
