import 'package:flutter/material.dart';
import '../../../../view_models/character/character_inventory_view_model.dart';
import '../../../utils/styled_dropdown.dart';
import '../../../../utils/app_theme.dart';

class WeaponAddDropdown extends StatefulWidget {
  final List<WeaponModel> allWeapons;
  final CharacterInventoryViewModel inv;

  const WeaponAddDropdown({super.key, required this.allWeapons, required this.inv});

  @override
  State<WeaponAddDropdown> createState() => _WeaponAddDropdownState();
}

class _WeaponAddDropdownState extends State<WeaponAddDropdown> {
  WeaponModel? _pending;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StyledDropdown<WeaponModel>(
          value: _pending,
          items: [null, ...widget.allWeapons],
          labelBuilder: (w) => w == null
              ? '-- Select weapon to add'
              : '${w.name} ${w.damageDice} (${w.cost})',
          onChanged: (w) => setState(() => _pending = w),
          icon: Icons.add_circle_outline,
        ),
        if (_pending != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                widget.inv.addWeapon(_pending!);
                setState(() => _pending = null);
              },
              icon: const Icon(Icons.add, size: 16),
              label: Text('Add Weapon'),
            ),
          ),
        ],
      ],
    );
  }
}
