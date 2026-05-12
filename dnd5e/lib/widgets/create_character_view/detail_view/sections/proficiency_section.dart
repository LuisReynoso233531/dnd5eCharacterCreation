import 'package:flutter/material.dart';
import '../../../../view_models/character/character_view_model.dart';
import '../section_title.dart';

Widget buildProficienciesSection(CreateCharacterViewModel vm) {
  final hasAny = vm.armorProficiencies.isNotEmpty ||
      vm.weaponProficiencies.isNotEmpty ||
      vm.toolProficiencies.isNotEmpty ||
      vm.racialSkillProfFromTraits.isNotEmpty;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Armor, Weapons & Tools"),
      const SizedBox(height: 4),

      if (!hasAny)
        const Text(
          "Select a class, race or background to see proficiencies.",
          style: TextStyle(color: Colors.grey),
        ),

      if (vm.armorProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Armor",
          vm.armorProficiencies,
          Colors.blueGrey,
          Icons.security,
        ),

      if (vm.weaponProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Weapons",
          vm.weaponProficiencies,
          Colors.orange.shade800,
          Icons.gavel,
        ),

      if (vm.toolProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Tools & Kits",
          vm.toolProficiencies,
          Colors.brown,
          Icons.handyman,
        ),

      // Skills raciales (separadas de las skill proficiencies del personaje)
      if (vm.racialSkillProfFromTraits.isNotEmpty)
        _buildProficiencyTag(
          "Racial Skills",
          vm.racialSkillProfFromTraits,
          Colors.teal,
          Icons.auto_awesome,
        ),
    ],
  );
}

Widget _buildProficiencyTag(
    String label, List<String> items, Color color, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
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
          children: items.map((p) => Chip(
            label: Text(p, style: const TextStyle(fontSize: 12, color: Colors.white)),
            backgroundColor: color.withOpacity(0.75),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          )).toList(),
        ),
      ],
    ),
  );
}