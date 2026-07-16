import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../view_models/character/character_detail_class_view_model.dart';
import '../../../view_models/character/character_inventory_view_model.dart';
import '../../../view_models/character/character_view_model.dart';

class CharacterSheetSummaryCard extends StatelessWidget {
  final CreateCharacterViewModel vm;
  final CharacterInventoryViewModel invVM;
  final DetailClassViewModel? detailVM;

  const CharacterSheetSummaryCard({
    super.key,
    required this.vm,
    required this.invVM,
    this.detailVM,
  });

  @override
  Widget build(BuildContext context) {
    final proficiencyBonus = CreateCharacterViewModel.proficiencyBonus(vm.level);
    final manualHp = detailVM?.calculateTotalHP() ?? 0;
    final maxHp = manualHp > 0 ? manualHp : vm.maxHp;
    final armorClass = invVM.calculateTotalAC(
      dexMod: vm.getModifier('Dexterity'),
      conMod: vm.getModifier('Constitution'),
      wisMod: vm.getModifier('Wisdom'),
    );
    final primary = context.colors.primary;
    final darkerPrimary = Color.lerp(primary, Colors.black, 0.34)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, darkerPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.name.isNotEmpty ? vm.name : '(Unnamed Character)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (vm.selectedClass != null)
                _summaryChip(
                  '${vm.selectedClass!.name} ${vm.level}',
                  Icons.military_tech,
                ),
              if (vm.selectedRace != null)
                _summaryChip(vm.selectedRace!['name'] ?? '', Icons.face),
              if (vm.selectedBackground != null)
                _summaryChip(
                  vm.selectedBackground!['name'] ?? '',
                  Icons.history_edu,
                ),
              _summaryChip('HP: $maxHp', Icons.favorite),
              _summaryChip('AC: $armorClass', Icons.shield),
              _summaryChip('Prof: +$proficiencyBonus', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
