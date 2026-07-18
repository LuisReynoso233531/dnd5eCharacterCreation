import 'package:flutter/material.dart';

import '../../../view_models/character/character_view_model.dart';
import '../../../view_models/character/character_inventory_view_model.dart';
import 'armor_class_card.dart';
import 'background_equipment_card.dart';
import './section/armor_section.dart';
import './section/weapon_section.dart';
import './section/tool_section.dart';
import './section/money_section.dart';
//import './section/treasures_section.dart';
import 'generate_sheet_button.dart';
import './section/inventory_section.dart';

class CharacterInventoryContent extends StatelessWidget {
  final CreateCharacterViewModel characterVM;
  final CharacterInventoryViewModel inventoryVM;
  final _toolController = TextEditingController();

  ///final _treasuresController = TextEditingController();

  CharacterInventoryContent({
    super.key,
    required this.characterVM,
    required this.inventoryVM,
  });

  @override
  Widget build(BuildContext context) {
    final dexMod = characterVM.getModifier('Dexterity');
    final conMod = characterVM.getModifier('Constitution');
    final wisMod = characterVM.getModifier('Wisdom');

    final acCalculation = inventoryVM.calculateArmorClass(
      characterClass: characterVM.selectedClass,
      dexMod: dexMod,
      conMod: conMod,
      wisMod: wisMod,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArmorClassCard(
            totalAC: acCalculation.value,
            calculationLabel: acCalculation.label,
            calculationFormula: acCalculation.formula,
            equippedArmor: inventoryVM.equippedArmor,
            equippedShield: inventoryVM.equippedShield,
          ),

          const SizedBox(height: 24),

          if (inventoryVM.backgroundEquipmentText.isNotEmpty) ...[
            InventorySection(
              title: 'Background Equipment',
              subtitle: 'Choose the equipment.',
              icon: Icons.history_edu,
              child: BackgroundEquipmentCard(
                text: inventoryVM.backgroundEquipmentText,
              ),
            ),
            const SizedBox(height: 24),
          ],

          InventorySection(
            title: 'Armors',
            subtitle: 'Choose your armor and shield.',
            icon: Icons.security,
            child: ArmorSection(inv: inventoryVM, dexMod: dexMod),
          ),

          const SizedBox(height: 24),

          InventorySection(
            title: 'Weapons',
            subtitle: 'Choose your weapons.',
            icon: Icons.gavel,
            child: WeaponSection(inv: inventoryVM),
          ),

          const SizedBox(height: 24),

          InventorySection(
            title: 'Tools',
            subtitle: 'Add your tools.',
            icon: Icons.handyman,
            child: ToolSection(inv: inventoryVM, controller: _toolController),
          ),

          const SizedBox(height: 24),

          InventorySection(
            title: 'Money',
            subtitle: 'Your current wealth.',
            icon: Icons.monetization_on,
            child: MoneySection(inv: inventoryVM),
          ),

          const SizedBox(height: 24),

          GenerateSheetButton(inventoryVM: inventoryVM),
        ],
      ),
    );
  }
}
