import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_skill_view_model.dart';

class ExpertiseSection extends StatelessWidget {
  final CharacterSkillViewModel skillVM;
  final String classSlug;
  final int characterLevel;
  final List<String> availableProficiencies;
  final int proficiencyBonus;

  const ExpertiseSection({
    super.key,
    required this.skillVM,
    required this.classSlug,
    required this.characterLevel,
    required this.availableProficiencies,
    required this.proficiencyBonus,
  });

  @override
  Widget build(BuildContext context) {
    final choiceCount = skillVM.expertiseChoiceCount(
      classSlug: classSlug,
      characterLevel: characterLevel,
    );

    if (choiceCount == 0) {
      return const SizedBox.shrink();
    }

    final options =
        availableProficiencies
            .where((item) => item.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final selected = skillVM.selectedExpertise;
    final canChooseThievesTools = options.contains(
      CharacterSkillViewModel.thievesToolsExpertise,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.workspace_premium, size: 20, color: Color(0xFF6A1B9A)),
            SizedBox(width: 8),
            Text(
              'Expertise',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          canChooseThievesTools
              ? 'Choose $choiceCount proficient skills, or Thieves\' Tools. '
                    'For each choice, your proficiency bonus is added twice.'
              : 'Choose $choiceCount proficient skills. '
                    'For each choice, your proficiency bonus is added twice.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Normal proficiency: ability modifier + $proficiencyBonus\n'
            'Expertise: ability modifier + ${proficiencyBonus * 2}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        if (options.isEmpty)
          Text(
            'Complete your skill proficiency selections first.',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else
          ...List.generate(choiceCount, (index) {
            final current =
                selected.length > index && selected[index].isNotEmpty
                ? selected[index]
                : null;

            final validCurrent = current != null && options.contains(current)
                ? current
                : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                key: ValueKey('expertise-$index-$validCurrent'),
                isExpanded: true,
                initialValue: validCurrent,
                decoration: InputDecoration(
                  labelText: 'Expertise ${index + 1}',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.stars),
                ),
                items: options.map((option) {
                  final selectedElsewhere = selected.asMap().entries.any(
                    (entry) => entry.key != index && entry.value == option,
                  );

                  return DropdownMenuItem<String>(
                    value: option,
                    enabled: !selectedElsewhere,
                    child: Text(
                      option,
                      style: TextStyle(
                        color: selectedElsewhere
                            ? context.dndColors.subtleText
                            : null,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  skillVM.setExpertiseAt(
                    index: index,
                    proficiency: value,
                    maxChoices: choiceCount,
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}
