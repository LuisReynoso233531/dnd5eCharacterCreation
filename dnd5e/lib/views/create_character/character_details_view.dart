import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';

class CharacterDetailsView extends StatelessWidget {
  const CharacterDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skills & Equipment"),
        backgroundColor: const Color(0xFFE50914),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN SKILLS ---
            const Text("Skill Proficiencies",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Chips de habilidades fijas
            Wrap(
              spacing: 8,
              children: vm.totalFixedSkills
                  .map((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: Colors.grey[300],
                        avatar: const Icon(Icons.lock, size: 16),
                      ))
                  .toList(),
            ),

            const Divider(),

            if (vm.skillChoices.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Make your skill selections:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ),
              Builder(builder: (context) {
                int globalIdx = 0;
                return Column(
                  children: vm.skillChoices.map((choice) {
                    return Column(
                      children: List.generate(choice.count, (i) {
                        final int currentIndex = globalIdx++;
                        final String? selectedValue =
                            vm.selectedClassSkills.length > currentIndex
                                ? vm.selectedClassSkills[currentIndex]
                                : null;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: "Option from: ${choice.options.take(2).join(', ')}...",
                              border: const OutlineInputBorder(),
                            ),
                            value: (selectedValue != null && choice.options.contains(selectedValue))
                                ? selectedValue
                                : null,
                            items: choice.options.map((skill) {
                              bool isFixed = vm.totalFixedSkills.contains(skill);
                              bool isAlreadyChosen = vm.selectedClassSkills.contains(skill) && skill != selectedValue;

                              return DropdownMenuItem(
                                value: skill,
                                enabled: !isFixed && !isAlreadyChosen,
                                child: Text(skill,
                                    style: TextStyle(
                                        color: (isFixed || isAlreadyChosen)
                                            ? Colors.grey
                                            : Colors.black)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                List<String> current = List.from(vm.selectedClassSkills);
                                while (current.length <= currentIndex) current.add("");
                                current[currentIndex] = val;
                                vm.confirmClassSkills(current);
                              }
                            },
                          ),
                        );
                      }),
                    );
                  }).toList(),
                );
              }),
            ],

            const SizedBox(height: 30),

            // --- SECCIÓN EQUIPMENT ---
            const Text(
              "Starting Equipment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 1. Selector de Pack (A, B, C)
            if (vm.equipmentPackages.isNotEmpty) ...[
              const Text("Choose your class equipment set:",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: vm.selectedPackageIndex,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.red.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.inventory, color: Color(0xFFE50914)),
                ),
                items: List.generate(vm.equipmentPackages.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text("Option ${vm.equipmentPackages[i].letter}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }),
                onChanged: (val) => vm.setPackageIndex(val!),
              ),
              const SizedBox(height: 15),
            ],

            // 2. Tarjeta con el equipo resultante (Fijo + Pack Seleccionado)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8)),
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: vm.totalEquipment.isEmpty 
                    ? [const Text("No equipment selected")]
                    : vm.totalEquipment.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shield, size: 18, color: Colors.brown),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(fontSize: 14, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}