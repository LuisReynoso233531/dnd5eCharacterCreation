import 'package:flutter/material.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../view_models/character/character_subclass_view_model.dart'; // Asegúrate de importar el VM
import '../../../../utils/app_theme.dart';
import 'info_box.dart';
import 'archetype_card.dart';

Widget subclassSection(
  BuildContext context, {
  required DetailClassViewModel dvm,
  required CharacterSubclassViewModel subclassVM, 
  required List<Map<String, dynamic>> archetypes,
  required String subtypesName,
  required bool canChoose,
  required int unlockLevel,
  required List<String> existingSkills, 
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.primaryRed, size: 20),
          const SizedBox(width: 8),
          Text(
            subtypesName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 10),

      if (!canChoose)
        infoBox(
          icon: Icons.lock_outline,
          color: Colors.amber,
          text: 'Your $subtypesName unlocks at level $unlockLevel.',
        ),

      if (canChoose) ...[
        if (dvm.selectedArchetype == null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Choose your ${subtypesName.toLowerCase()}:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryRed,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Selected: ${dvm.selectedArchetype!['name']}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],

      // ── Mapeo de Tarjetas de Subclase ──
      ...archetypes.map((arch) {
        return archetypeCard(
          context,
          arch: arch,
          dvm: dvm,
          canChoose: canChoose,
        );
      }),
      if (canChoose &&
          (dvm.selectedArchetype != null ||
              subclassVM.pendingChoicesCount > 0 ||
              subclassVM.automaticSkills.isNotEmpty)) ...[
        const SizedBox(height: 16),

        // A. Mostrar habilidades fijas automáticas otorgadas
        if (subclassVM.automaticSkills.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              '✨ Automatic Proficiencies Granted:\n${subclassVM.automaticSkills.join(', ')}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (subclassVM.availableOptionsForChoice.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Choose ${subclassVM.pendingChoicesCount} Bonus Skills:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    subclassVM.selectedBonusSkills.length ==
                        subclassVM.pendingChoicesCount
                    ? Colors.green
                    : AppTheme.primaryRed,
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: subclassVM.availableOptionsForChoice.map((skill) {
              final isSkillSelected = subclassVM.selectedBonusSkills.contains(
                skill,
              );
              return FilterChip(
                label: Text(skill),
                selected: isSkillSelected,
                selectedColor: AppTheme.primaryRed.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryRed,
                onSelected: (bool selected) {
                  subclassVM.toggleBonusSkill(skill);
                },
              );
            }).toList(),
          ),
        ],
      ],
    ],
  );
}
