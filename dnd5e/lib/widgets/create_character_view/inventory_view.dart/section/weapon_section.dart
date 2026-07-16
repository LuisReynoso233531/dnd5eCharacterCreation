import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_inventory_view_model.dart';
import '../weapon_add_dropdown.dart';

class WeaponSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;

  const WeaponSection({super.key, required this.inv});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...inv.weaponEntries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.dndColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.dndColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gavel,
                          size: 16,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.weapon.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${entry.weapon.damageDice} ${entry.weapon.damageType}'
                                '${entry.weapon.properties.isNotEmpty ? ' · ${entry.weapon.properties.take(2).join(', ')}' : ''}',
                                style: TextStyle(
                                  color: context.dndColors.mutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _QuantityPicker(
                  value: entry.quantity,
                  onDecrement: () => inv.updateWeaponQuantity(
                    entry.weapon.slug,
                    entry.quantity - 1,
                  ),
                  onIncrement: () => inv.updateWeaponQuantity(
                    entry.weapon.slug,
                    entry.quantity + 1,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: context.colors.primary,
                  ),
                  onPressed: () => inv.removeWeapon(entry.weapon.slug),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        WeaponAddDropdown(allWeapons: inv.allWeapons, inv: inv),
      ],
    );
  }
}

class _QuantityPicker extends StatelessWidget {
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityPicker({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.dndColors.surfaceRaised,
        border: Border.all(color: context.dndColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove, size: 14),
              onPressed: onDecrement,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(
            width: 28,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 14),
              onPressed: onIncrement,
            ),
          ),
        ],
      ),
    );
  }
}
