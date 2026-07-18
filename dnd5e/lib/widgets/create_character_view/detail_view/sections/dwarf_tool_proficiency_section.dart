import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_view_model.dart';
import '../section_title.dart';

Widget buildDwarvenToolProficiencySection(
  CreateCharacterViewModel vm,
) {
  if (!vm.requiresDwarvenToolProficiencyChoice) {
    return const SizedBox.shrink();
  }

  return Builder(
    builder: (context) {
      final selected = vm.selectedDwarvenToolProficiency;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Dwarven Tool Proficiency'),
          const SizedBox(height: 6),
          Text(
            'Choose one artisan tool proficiency granted by your dwarf race.',
            style: TextStyle(
              fontSize: 13,
              color: context.dndColors.mutedText,
            ),
          ),
          const SizedBox(height: 12),
          ...CreateCharacterViewModel.dwarvenToolProficiencyOptions.map(
            (tool) {
              final isSelected = selected == tool;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isSelected
                      ? context.colors.primaryContainer
                      : context.dndColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => vm.setDwarvenToolProficiency(tool),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.dndColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? context.colors.primary
                                : context.dndColors.subtleText,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tool,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? context.colors.onPrimaryContainer
                                    : context.colors.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.handyman_outlined,
                            size: 20,
                            color: isSelected
                                ? context.colors.primary
                                : context.dndColors.subtleText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (selected == null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'A tool must be selected before continuing.',
                style: TextStyle(
                  color: context.colors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      );
    },
  );
}
