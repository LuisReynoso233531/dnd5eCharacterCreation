import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../view_models/character/character_inventory_view_model.dart';

class ArmorClassCard extends StatelessWidget {
  const ArmorClassCard({
    super.key,
    required this.totalAC,
    required this.calculationLabel,
    required this.calculationFormula,
    required this.equippedArmor,
    required this.equippedShield,
  });

  final int totalAC;
  final String calculationLabel;
  final String calculationFormula;
  final ArmorModel? equippedArmor;
  final ArmorModel? equippedShield;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final darkerPrimary = Color.lerp(primary, Colors.black, 0.34)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, darkerPrimary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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

              const SizedBox(width: 12),
              const Spacer(),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ArmorChip(label: equippedArmor?.name ?? calculationLabel),

                    if (equippedShield != null) ...[
                      const SizedBox(height: 5),
                      _ArmorChip(label: '+ ${equippedShield!.name}'),
                    ],

                    if (equippedArmor?.stealthDisadvantage == true) ...[
                      const SizedBox(height: 5),
                      const _ArmorChip(label: 'Stealth disadvantage'),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              calculationFormula,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArmorChip extends StatelessWidget {
  const _ArmorChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
