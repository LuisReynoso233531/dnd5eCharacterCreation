import 'package:flutter/material.dart';
import '../../../../view_models/character/character_inventory_view_model.dart';
import '../../../../utils/styled_dropdown.dart';

class ArmorSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  final int dexMod;

  const ArmorSection({super.key, required this.inv, required this.dexMod});

  String _armorLabel(ArmorModel a) {
    final ac = a.calculateAC(dexMod: dexMod);
    return '${a.name}, CA $ac (${a.cost})';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Armadura principal
        StyledDropdown<ArmorModel>(
          value: inv.equippedArmor,
          items: [null, ...inv.regularArmors],
          labelBuilder: (a) => a == null ? '-- No armor' : _armorLabel(a),
          onChanged: inv.equipArmor,
          icon: Icons.security,
        ),
        const SizedBox(height: 10),

        // Escudo
        StyledDropdown<ArmorModel>(
          value: inv.equippedShield,
          items: [null, ...inv.shields],
          labelBuilder: (s) => s == null
              ? '-- No shield'
              : '${s.name}, CA ${s.acString} (${s.cost})',
          onChanged: inv.equipShield,
          icon: Icons.shield,
        ),

        // Aviso de requisito de fuerza
        if (inv.equippedArmor?.strengthReq != null &&
            inv.equippedArmor!.strengthReq! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Requires STR ${inv.equippedArmor!.strengthReq}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}