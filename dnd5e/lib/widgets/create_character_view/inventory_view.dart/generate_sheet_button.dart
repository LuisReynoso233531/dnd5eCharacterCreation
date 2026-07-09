import 'package:flutter/material.dart';
import '../../../../utils/provider_extensions.dart';
import '../../../views/create_character/charecter_sheet_view.dart';
import '../../../view_models/character/character_inventory_view_model.dart';
import '../../../view_models/character/character_detail_class_view_model.dart';
import '../../../view_models/character/character_subclass_view_model.dart';
import '../../../view_models/character/character_spell_view_model.dart';

class GenerateSheetButton extends StatelessWidget {
  final CharacterInventoryViewModel inventoryVM;

  const GenerateSheetButton({
    super.key,
    required this.inventoryVM,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _goToSheet(context),
        icon: const Icon(Icons.picture_as_pdf, size: 22),
        label: const Text(
          'Generate Character Sheet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  void _goToSheet(BuildContext context) {
    final detailVM = context.readOrNull<DetailClassViewModel>();
    final subclassVM = context.readOrNull<CharacterSubclassViewModel>();
    final spellVM = context.readOrNull<CharacterSpellViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterSheetView(
          invVM: inventoryVM,
          detailVM: detailVM,
          subclassVM: subclassVM,
          spellVM: spellVM,
        ),
      ),
    );
  }
}