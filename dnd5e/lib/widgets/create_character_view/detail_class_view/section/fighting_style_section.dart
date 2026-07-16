import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';

Widget fightingStyleSection(
  DetailClassViewModel dvm,
  dynamic charClass,
  int currentLevel,
) {
  final availableStyles = dvm.getAvailableFightingStyles(
    charClass,
    currentLevel,
  );
  if (availableStyles.isEmpty) return const SizedBox.shrink();

  final selectedStyle = availableStyles.firstWhere(
    (style) => style['name'] == dvm.selectedFightingStyleName,
    orElse: () => <String, String>{},
  );

  return Builder(
    builder: (context) {
      final accent = context.dndColors.info;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sports_martial_arts, color: accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Fighting Style',
                style: context.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue:
                availableStyles.any(
                  (style) => style['name'] == dvm.selectedFightingStyleName,
                )
                ? dvm.selectedFightingStyleName
                : null,
            decoration: InputDecoration(
              labelText: 'Select Fighting Style',
              prefixIcon: Icon(Icons.shield_outlined, color: accent),
            ),
            items: availableStyles
                .map(
                  (style) => DropdownMenuItem<String>(
                    value: style['name']?.toString(),
                    child: Text(style['name']?.toString() ?? ''),
                  ),
                )
                .toList(),
            onChanged: dvm.setFightingStyleName,
          ),
          if (selectedStyle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.dndColors.infoContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.55)),
              ),
              child: Text(
                selectedStyle['desc']?.toString() ?? '',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: context.dndColors.onInfoContainer,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      );
    },
  );
}
