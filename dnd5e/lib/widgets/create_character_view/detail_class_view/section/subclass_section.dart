import 'package:flutter/material.dart';
import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../view_models/character/character_subclass_view_model.dart';
import 'archetype_card.dart';
import 'info_box.dart';

Widget subclassSection(
  BuildContext context, {
  required DetailClassViewModel dvm,
  required CharacterSubclassViewModel subclassVM,
  required List<Map<String, dynamic>> archetypes,
  required String subtypesName,
  required bool canChoose,
  required int unlockLevel,
  required int characterLevel,
  required List<String> existingSkills,
}) {
  final grantedSpells = subclassVM.grantedSpellsForLevel(characterLevel);

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
                Expanded(
                  child: Text(
                    'Selected: ${dvm.selectedArchetype!['name']}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],

      ...archetypes.map(
        (arch) => archetypeCard(
          context,
          arch: arch,
          dvm: dvm,
          canChoose: canChoose,
        ),
      ),

      if (canChoose &&
          (dvm.selectedArchetype != null ||
              subclassVM.pendingChoicesCount > 0 ||
              subclassVM.automaticSkills.isNotEmpty)) ...[
        const SizedBox(height: 16),

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
              'Automatic Proficiencies Granted:\n'
              '${subclassVM.automaticSkills.join(', ')}',
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
            spacing: 8,
            runSpacing: 4,
            children: subclassVM.availableOptionsForChoice.map((skill) {
              final selected = subclassVM.selectedBonusSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: selected,
                selectedColor: AppTheme.primaryRed.withOpacity(0.2),
                checkmarkColor: AppTheme.primaryRed,
                onSelected: (_) => subclassVM.toggleBonusSkill(skill),
              );
            }).toList(),
          ),
        ],
      ],

      if (canChoose &&
          dvm.selectedArchetype != null &&
          (subclassVM.spellTables.isNotEmpty || grantedSpells.isNotEmpty)) ...[
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6A1B9A).withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF6A1B9A).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_fix_high, size: 17, color: Color(0xFF6A1B9A)),
                  SizedBox(width: 6),
                  Text(
                    'Subclass Spells',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                ],
              ),
              if (subclassVM.requiresSpellTableChoice) ...[
                const SizedBox(height: 8),
                const Text(
                  'Choose the spell list granted by this subclass:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: subclassVM.spellTables.map((table) {
                    return ChoiceChip(
                      label: Text(table.title),
                      selected:
                          subclassVM.selectedSpellTableId == table.id,
                      onSelected: (_) =>
                          subclassVM.selectSpellTable(table.id),
                    );
                  }).toList(),
                ),
              ],
              if (subclassVM.selectedSpellTable != null ||
                  grantedSpells.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  grantedSpells.isEmpty
                      ? 'No subclass spells are unlocked at level $characterLevel.'
                      : 'Granted automatically at level $characterLevel:\n'
                          '${grantedSpells.map((grant) => grant.spellName).join(', ')}',
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                if (grantedSpells.any(
                  (grant) => !grant.countsAgainstLimit,
                )) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Bonus granted spells do not count against your normal spell limit.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (grantedSpells.any(
                  (grant) => grant.countsAgainstLimit,
                )) ...[
                  const SizedBox(height: 6),
                  const Text(
                    'Required spells are selected automatically, but still count toward the subclass limit.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    ],
  );
}
