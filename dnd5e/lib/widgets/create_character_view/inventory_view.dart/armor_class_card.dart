import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../view_models/character/character_inventory_view_model.dart';

class ArmorClassCard extends StatelessWidget {
  final int totalAC;
  final ArmorModel? equippedArmor;
  final ArmorModel? equippedShield;

  const ArmorClassCard({
    super.key,
    required this.totalAC,
    required this.equippedArmor,
    required this.equippedShield,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withOpacity(0.85),
            AppTheme.primaryRed.withOpacity(0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Armor Class',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '$totalAC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Chip(label: equippedArmor?.name ?? 'Unarmored'),
              if (equippedShield != null) ...[
                const SizedBox(height: 4),
                _Chip(label: '+ ${equippedShield!.name}'),
              ],
              if (equippedArmor?.stealthDisadvantage == true) ...[
                const SizedBox(height: 4),
                const _Chip(label: 'Stealth disadv.'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}