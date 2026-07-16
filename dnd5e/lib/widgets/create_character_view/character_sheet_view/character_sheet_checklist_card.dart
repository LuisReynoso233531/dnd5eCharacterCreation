import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../view_models/character/character_view_model.dart';

class CharacterSheetChecklistCard extends StatelessWidget {
  final CreateCharacterViewModel vm;

  const CharacterSheetChecklistCard({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _Check('Name set', vm.name.isNotEmpty),
      _Check('Race selected', vm.selectedRace != null),
      _Check('Class selected', vm.selectedClass != null),
      _Check('Background set', vm.selectedBackground != null),
      _Check(
        'Level improvements complete',
        vm.isLevelUpComplete || vm.availableImprovementLevels.isEmpty,
      ),
      _Check(
        'Skills selected',
        vm.skillVM.selectedClassSkills.isNotEmpty ||
            vm.skillVM.totalFixedSkills().isNotEmpty,
      ),
    ];

    final done = items.where((i) => i.done).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dndColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dndColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.18 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Completeness',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Text(
                '$done/${items.length}',
                style: TextStyle(
                  color: done == items.length ? context.dndColors.success : context.dndColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: done / items.length,
              backgroundColor: context.dndColors.surfaceStrong,
              valueColor: AlwaysStoppedAnimation(
                done == items.length ? context.dndColors.success : context.dndColors.warning,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    item.done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: item.done ? context.dndColors.success : context.dndColors.subtleText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: item.done ? context.colors.onSurface : context.dndColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Check {
  final String label;
  final bool done;

  _Check(this.label, this.done);
}
