import 'package:flutter/material.dart';
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
    (s) => s['name'] == dvm.selectedFightingStyleName,
    orElse: () => {},
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(Icons.sports_martial_arts, color: Colors.indigo, size: 20),
          SizedBox(width: 8),
          Text(
            'Fighting Style',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Select Fighting Style',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.indigo.shade50,
        ),
        value:
            availableStyles.any(
              (s) => s['name'] == dvm.selectedFightingStyleName,
            )
            ? dvm.selectedFightingStyleName
            : null,
        items: availableStyles
            .map(
              (s) => DropdownMenuItem<String>(
                value: s['name'],
                child: Text(s['name'] ?? ''),
              ),
            )
            .toList(),
        onChanged: (val) => dvm.setFightingStyleName(val),
      ),
      if (selectedStyle.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Text(
            selectedStyle['desc'] ?? '',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    ],
  );
}
