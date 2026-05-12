import 'package:flutter/material.dart';
import '../../../../view_models/character/character_equipment_view_model.dart';
import '../item_tile.dart';
import '../section_title.dart';
import '../sub_section_title.dart';


Widget buildEquipmentSection(CharacterEquipmentViewModel vm) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Starting Equipment"),

      if (vm.backgroundEquipment.isEmpty &&
          vm.fixedEquipment.isEmpty &&
          vm.equipmentPackages.isEmpty)
        const Text(
          "Select a class and background to see equipment.",
          style: TextStyle(color: Colors.grey),
        ),

      // Equipo del background
      if (vm.backgroundEquipment.isNotEmpty) ...[
        const SubSectionTitle("Background Equipment"),
        ...vm.backgroundEquipment.map(
          (e) => itemTile(e, Icons.history_edu, Colors.blueGrey),
        ),
      ],

      // Equipo fijo de la clase
      if (vm.fixedEquipment.isNotEmpty) ...[
        const SubSectionTitle("Class Fixed Equipment"),
        ...vm.fixedEquipment.map(
          (e) => itemTile(e, Icons.shield, Colors.brown),
        ),
      ],

      // Paquetes de equipamiento (A / B / C)
      if (vm.equipmentPackages.isNotEmpty) ...[
        const SubSectionTitle("Choose a Package"),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: vm.selectedPackageIndex,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.red[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: List.generate(vm.equipmentPackages.length, (i) {
            return DropdownMenuItem(
              value: i,
              child: Text(
                "Option ${vm.equipmentPackages[i].letter}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),
          onChanged: (val) => vm.setPackageIndex(val!),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Items in Option ${vm.equipmentPackages[vm.selectedPackageIndex].letter}:",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...vm.equipmentPackages[vm.selectedPackageIndex].items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text("• $item", style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
