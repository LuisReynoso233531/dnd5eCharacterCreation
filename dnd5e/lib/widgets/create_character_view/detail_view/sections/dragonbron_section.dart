import 'package:flutter/material.dart';
import '../../../../view_models/character/character_view_model.dart';
// Este widget lo puedes colocar justo arriba o debajo de tu sección de Skills
Widget buildDragonbornAncestrySection(CreateCharacterViewModel vm) {
  // Validamos estrictamente el slug
  if (vm.selectedRace?['slug'] != 'dragonborn') {
    return const SizedBox.shrink(); // No dibuja nada si no es Dragonborn
  }

  final selected = vm.selectedDraconicAncestry;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
          SizedBox(width: 8),
          Text(
            "Draconic Ancestry",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        "Choose your draconic ancestry to determine your breath weapon and damage resistance.",
        style: TextStyle(fontSize: 13, color: Colors.black54),
      ),
      const SizedBox(height: 12),
      
      // Dropdown para seleccionar el tipo de dragón
      DropdownButtonFormField<Map<String, String>>(
        decoration: InputDecoration(
          labelText: "Dragon Type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.orange.shade50,
          prefixIcon: const Icon(Icons.pets, color: Colors.deepOrange),
        ),
        value: selected,
        items: CreateCharacterViewModel.draconicAncestries.map((ancestry) {
          return DropdownMenuItem(
            value: ancestry,
            child: Text(
              "${ancestry['dragon']} (${ancestry['damage_type']})",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        }).toList(),
        onChanged: (val) => vm.setDraconicAncestry(val),
      ),

      // Tarjeta de información que aparece cuando ya seleccionó uno
      if (selected != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.deepOrange.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("Resistance: ${selected['damage_type']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(Icons.air, size: 16, color: Colors.teal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text("Breath Weapon: ${selected['breath_weapon']}", 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 24), // Espaciado final
    ],
  );
}