import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';

import 'character_sheet/character_sheet_builder.dart';
import 'character_sheet/character_sheet_data.dart';
import 'character_sheet/character_sheet_pdf_generator.dart';

export 'character_sheet/character_sheet_data.dart';

class CharacterSheetService {
  static CharacterSheetData buildData({
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
    return CharacterSheetBuilder.build(
      vm: vm,
      invVM: invVM,
      spellVM: spellVM,
      detailVM: detailVM,
      subclassVM: subclassVM,
      playerName: playerName,
      alignment: alignment,
      temporaryHp: temporaryHp,
      personalityTraits: personalityTraits,
      ideals: ideals,
      bonds: bonds,
      flaws: flaws,
    );
  }

  static Future<String> generatePdf({
    required CharacterSheetData d,
    required String blankPdfAssetPath,
  }) {
    return CharacterSheetPdfGenerator.generate(
      d: d,
      blankPdfAssetPath: blankPdfAssetPath,
    );
  }
}
