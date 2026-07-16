import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_view_model.dart';
import '../section_title.dart';

Widget buildProficienciesSection(CreateCharacterViewModel vm) {
  return Builder(
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Proficiencies'),
        if (vm.armorProficiencies.isEmpty &&
            vm.weaponProficiencies.isEmpty &&
            vm.toolProficiencies.isEmpty &&
            vm.racialSkillProfFromTraits.isEmpty &&
            vm.featProficiencies.isEmpty)
          Text(
            'Select a class and race to see proficiencies.',
            style: TextStyle(color: context.dndColors.mutedText),
          ),
        if (vm.armorProficiencies.isNotEmpty)
          _buildProficiencyTag(
            context,
            'Armor',
            vm.armorProficiencies,
            context.dndColors.info,
            Icons.security,
          ),
        if (vm.weaponProficiencies.isNotEmpty)
          _buildProficiencyTag(
            context,
            'Weapons',
            vm.weaponProficiencies,
            context.dndColors.warning,
            Icons.gavel,
          ),
        if (vm.toolProficiencies.isNotEmpty)
          _buildProficiencyTag(
            context,
            'Tools & Kits',
            vm.toolProficiencies,
            context.isDarkMode ? const Color(0xFFD7B899) : Colors.brown,
            Icons.handyman,
          ),
        if (vm.racialSkillProfFromTraits.isNotEmpty)
          _buildProficiencyTag(
            context,
            'Racial Skills',
            vm.racialSkillProfFromTraits,
            context.dndColors.success,
            Icons.auto_awesome,
          ),
        if (vm.featProficiencies.isNotEmpty)
          _buildProficiencyTag(
            context,
            'From Feats',
            vm.featProficiencies,
            context.isDarkMode ? const Color(0xFFD7B3FF) : Colors.deepPurple,
            Icons.stars,
          ),
      ],
    ),
  );
}

Widget _buildProficiencyTag(
  BuildContext context,
  String label,
  List<String> items,
  Color color,
  IconData icon,
) {
  final onColor = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
      ? Colors.white
      : Colors.black;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map(
                (item) => Chip(
                  label: Text(
                    item,
                    style: TextStyle(fontSize: 12, color: onColor),
                  ),
                  backgroundColor: color.withValues(alpha: 0.82),
                  side: BorderSide(color: color),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}
