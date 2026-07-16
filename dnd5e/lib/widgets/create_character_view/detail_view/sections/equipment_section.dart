import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_equipment_view_model.dart';
import '../item_tile.dart';
import '../section_title.dart';
import '../sub_section_title.dart';

Widget buildEquipmentSection(CharacterEquipmentViewModel vm) {
  return Builder(
    builder: (context) {
      final selectedPackage = vm.equipmentPackages.isNotEmpty
          ? vm.equipmentPackages[vm.selectedPackageIndex]
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Starting Equipment'),
          if (vm.backgroundEquipment.isEmpty &&
              vm.fixedEquipment.isEmpty &&
              vm.equipmentPackages.isEmpty)
            Text(
              'Select a class and background to see equipment.',
              style: TextStyle(color: context.dndColors.mutedText),
            ),
          if (vm.backgroundEquipment.isNotEmpty) ...[
            const SubSectionTitle('Background Equipment'),
            ...vm.backgroundEquipment.map(
              (item) => itemTile(
                item,
                Icons.history_edu,
                context.dndColors.info,
              ),
            ),
          ],
          if (vm.fixedEquipment.isNotEmpty) ...[
            const SubSectionTitle('Class Fixed Equipment'),
            ...vm.fixedEquipment.map(
              (item) => itemTile(
                item,
                Icons.shield,
                context.isDarkMode
                    ? const Color(0xFFD7B899)
                    : Colors.brown,
              ),
            ),
          ],
          if (selectedPackage != null) ...[
            const SubSectionTitle('Choose a Package'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              key: ValueKey('equipment-package-${vm.selectedPackageIndex}'),
              initialValue: vm.selectedPackageIndex,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              items: List.generate(vm.equipmentPackages.length, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    'Option ${vm.equipmentPackages[index].letter}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) vm.setPackageIndex(value);
              },
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items in Option ${selectedPackage.letter}:',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedPackage.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('• $item'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    },
  );
}
