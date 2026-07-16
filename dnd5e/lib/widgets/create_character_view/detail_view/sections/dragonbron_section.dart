import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_view_model.dart';

Widget buildDragonbornAncestrySection(CreateCharacterViewModel vm) {
  if (vm.selectedRace?['slug'] != 'dragonborn') {
    return const SizedBox.shrink();
  }

  final selected = vm.selectedDraconicAncestry;

  return Builder(
    builder: (context) {
      final accent = context.isDarkMode
          ? const Color(0xFFFFB27A)
          : Colors.deepOrange;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Draconic Ancestry',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your draconic ancestry to determine your breath weapon '
            'and damage resistance.',
            style: TextStyle(
              fontSize: 13,
              color: context.dndColors.mutedText,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Map<String, String>>(
            key: ValueKey("dragonborn-${selected?['dragon']}"),
            initialValue: selected,
            decoration: InputDecoration(
              labelText: 'Dragon Type',
              prefixIcon: Icon(Icons.pets, color: accent),
            ),
            items: CreateCharacterViewModel.draconicAncestries.map((ancestry) {
              return DropdownMenuItem<Map<String, String>>(
                value: ancestry,
                child: Text(
                  "${ancestry['dragon']} (${ancestry['damage_type']})",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: vm.setDraconicAncestry,
          ),
          if (selected != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.dndColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accent.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDarkMode ? 0.18 : 0.05,
                    ),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield,
                        size: 16,
                        color: context.dndColors.info,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Resistance: ${selected['damage_type']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    children: [
                      Icon(Icons.air, size: 16, color: context.dndColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Breath Weapon: ${selected['breath_weapon']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      );
    },
  );
}
