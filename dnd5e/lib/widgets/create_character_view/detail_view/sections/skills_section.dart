import 'package:flutter/material.dart';
import '../../../../view_models/character/character_skill_view_model.dart';
  
  
  Widget buildSkillsSection(CharacterSkillViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.totalFixedSkills().isEmpty && vm.skillChoices.isEmpty)
          const Text(
            "Select a class and background to see skills.",
            style: TextStyle(color: Colors.grey),
          ),

        // Chips fijos
        if (vm.totalFixedSkills().isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: vm.totalFixedSkills()
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.grey[200],
                    avatar: const Icon(Icons.lock, size: 14),
                  ),
                )
                .toList(),
          ),

        // Dropdowns de elección
        if (vm.skillChoices.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            "Choose your skills:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              int globalIdx = 0;
              return Column(
                children: vm.skillChoices.map((choice) {
                  return Column(
                    children: List.generate(choice.count, (_) {
                      final idx = globalIdx++;
                      final selected = vm.selectedClassSkills.length > idx
                          ? vm.selectedClassSkills[idx]
                          : null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText:
                                "Pick from: ${choice.options.take(3).join(', ')}…",
                            border: const OutlineInputBorder(),
                          ),
                          value:
                              (selected != null &&
                                  choice.options.contains(selected))
                              ? selected
                              : null,
                          items: choice.options.map((skill) {
                            final isFixed = vm.totalFixedSkills().contains(skill);
                            final isTaken =
                                vm.selectedClassSkills.contains(skill) &&
                                skill != selected;
                            return DropdownMenuItem(
                              value: skill,
                              enabled: !isFixed && !isTaken,
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: (isFixed || isTaken)
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final current = List<String>.from(
                              vm.selectedClassSkills,
                            );
                            while (current.length <= idx) current.add('');
                            current[idx] = val;
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
  }