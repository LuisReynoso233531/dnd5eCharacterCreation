import 'package:flutter/material.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../utils/app_theme.dart';
import 'info_box.dart';
import 'archetype_card.dart';

Widget subclassSection(
  BuildContext context, {
  required DetailClassViewModel dvm,
  required List<Map<String, dynamic>> archetypes,
  required String subtypesName,
  required bool canChoose,
  required int unlockLevel,
}) {
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
                Text(
                  'Selected: ${dvm.selectedArchetype!['name']}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],

      ...archetypes.map(
        (arch) =>
            archetypeCard(context, arch: arch, dvm: dvm, canChoose: canChoose),
      ),
    ],
  );
}
