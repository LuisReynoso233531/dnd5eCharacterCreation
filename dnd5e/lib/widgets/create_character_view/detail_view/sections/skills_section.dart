import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_skill_view_model.dart';

Widget buildSkillsSection(CharacterSkillViewModel vm) {
  return Builder(
    builder: (context) {
      final fixedSkills = vm.totalFixedSkills();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fixedSkills.isEmpty && vm.skillChoices.isEmpty)
            Text(
              'Select a class and background to see skills.',
              style: TextStyle(color: context.dndColors.mutedText),
            ),
          if (fixedSkills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: fixedSkills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: context.dndColors.surfaceStrong,
                      avatar: const Icon(Icons.lock, size: 14),
                    ),
                  )
                  .toList(),
            ),
          if (vm.skillChoices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Choose your skills:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                var globalIndex = 0;

                return Column(
                  children: vm.skillChoices.map((choice) {
                    return Column(
                      children: List.generate(choice.count, (_) {
                        final index = globalIndex++;
                        final selected = vm.selectedClassSkills.length > index
                            ? vm.selectedClassSkills[index]
                            : null;
                        final validSelected = selected != null &&
                                choice.options.contains(selected)
                            ? selected
                            : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            key: ValueKey('class-skill-$index-$validSelected'),
                            isExpanded: true,
                            initialValue: validSelected,
                            decoration: InputDecoration(
                              labelText:
                                  'Pick from: ${choice.options.take(3).join(', ')}…',
                              prefixIcon: const Icon(Icons.psychology_outlined),
                            ),
                            items: choice.options.map((skill) {
                              final isFixed = fixedSkills.contains(skill);
                              final isTaken =
                                  vm.selectedClassSkills.contains(skill) &&
                                      skill != selected;

                              return DropdownMenuItem<String>(
                                value: skill,
                                enabled: !isFixed && !isTaken,
                                child: Text(
                                  skill,
                                  style: TextStyle(
                                    color: isFixed || isTaken
                                        ? context.dndColors.subtleText
                                        : null,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;

                              final current = List<String>.from(
                                vm.selectedClassSkills,
                              );
                              while (current.length <= index) {
                                current.add('');
                              }
                              current[index] = value;
                              vm.confirmClassSkills(current);
                            },
                          ),
                        );
                      }),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      );
    },
  );
}
