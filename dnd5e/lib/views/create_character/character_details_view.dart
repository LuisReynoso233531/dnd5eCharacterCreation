import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../data/models/character_class.dart';

class CharacterSkillAndEquipmentView extends StatelessWidget {
  const CharacterSkillAndEquipmentView({super.key});

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
        _buildSkillsSection(vm),
        const Divider(height: 40, thickness: 1.5),
        _buildProficienciesSection(vm), // ← NUEVO
        const Divider(height: 40, thickness: 1.5),
        _buildLanguagesSection(vm), // ← NUEVO
        const Divider(height: 40, thickness: 1.5),
        _buildEquipmentSection(vm),
        _sectionTitle("Skill Proficiencies"),
        const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── SKILLS ──────────────────────────────────────

  Widget _buildSkillsSection(CreateCharacterViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.totalFixedSkills.isEmpty && vm.skillChoices.isEmpty)
          const Text(
            "Select a class and background to see skills.",
            style: TextStyle(color: Colors.grey),
          ),

        // Chips fijos
        if (vm.totalFixedSkills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: vm.totalFixedSkills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.grey[200],
                    avatar: const Icon(Icons.lock, size: 14),
                  ),
                )
                .toList(),
          ),

        // Dropdowns de elección
        if (vm.skillChoices.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            "Choose your skills:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              int globalIdx = 0;
              return Column(
                children: vm.skillChoices.map((choice) {
                  return Column(
                    children: List.generate(choice.count, (_) {
                      final idx = globalIdx++;
                      final selected = vm.selectedClassSkills.length > idx
                          ? vm.selectedClassSkills[idx]
                          : null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText:
                                "Pick from: ${choice.options.take(3).join(', ')}…",
                            border: const OutlineInputBorder(),
                          ),
                          value:
                              (selected != null &&
                                  choice.options.contains(selected))
                              ? selected
                              : null,
                          items: choice.options.map((skill) {
                            final isFixed = vm.totalFixedSkills.contains(skill);
                            final isTaken =
                                vm.selectedClassSkills.contains(skill) &&
                                skill != selected;
                            return DropdownMenuItem(
                              value: skill,
                              enabled: !isFixed && !isTaken,
                              child: Text(
                                skill,
                                style: TextStyle(
                                  color: (isFixed || isTaken)
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final current = List<String>.from(
                              vm.selectedClassSkills,
                            );
                            while (current.length <= idx) current.add('');
                            current[idx] = val;
                            vm.confirmClassSkills(current);
                          },
                        ),
                      );
                    }),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }

  // ── EQUIPMENT ───────────────────────────────────

  Widget _buildEquipmentSection(CreateCharacterViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Starting Equipment"),

        if (vm.backgroundEquipment.isEmpty &&
            vm.fixedEquipment.isEmpty &&
            vm.equipmentPackages.isEmpty)
          const Text(
            "Select a class and background to see equipment.",
            style: TextStyle(color: Colors.grey),
          ),

        // Equipo del background
        if (vm.backgroundEquipment.isNotEmpty) ...[
          const _SubSectionTitle("Background Equipment"),
          ...vm.backgroundEquipment.map(
            (e) => _itemTile(e, Icons.history_edu, Colors.blueGrey),
          ),
        ],

        // Equipo fijo de la clase
        if (vm.fixedEquipment.isNotEmpty) ...[
          const _SubSectionTitle("Class Fixed Equipment"),
          ...vm.fixedEquipment.map(
            (e) => _itemTile(e, Icons.shield, Colors.brown),
          ),
        ],

        // Paquetes de equipamiento (A / B / C)
        if (vm.equipmentPackages.isNotEmpty) ...[
          const _SubSectionTitle("Choose a Package"),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: vm.selectedPackageIndex,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.red[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
                    child: Text(
                      "• $item",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );

  Widget _itemTile(String text, IconData icon, Color color) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(text, style: const TextStyle(fontSize: 14)),
    dense: true,
    contentPadding: EdgeInsets.zero,
  );
}

class _SubSectionTitle extends StatelessWidget {
  final String title;
  const _SubSectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );
}

Widget _buildProficienciesSection(CreateCharacterViewModel vm) {
  final hasAny = vm.armorProficiencies.isNotEmpty ||
      vm.weaponProficiencies.isNotEmpty ||
      vm.toolProficiencies.isNotEmpty ||
      vm.racialSkillProfFromTraits.isNotEmpty;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle("Armor, Weapons & Tools"),
      const SizedBox(height: 4),

      if (!hasAny)
        const Text(
          "Select a class, race or background to see proficiencies.",
          style: TextStyle(color: Colors.grey),
        ),

      if (vm.armorProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Armor",
          vm.armorProficiencies,
          Colors.blueGrey,
          Icons.security,
        ),

      if (vm.weaponProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Weapons",
          vm.weaponProficiencies,
          Colors.orange.shade800,
          Icons.gavel,
        ),

      if (vm.toolProficiencies.isNotEmpty)
        _buildProficiencyTag(
          "Tools & Kits",
          vm.toolProficiencies,
          Colors.brown,
          Icons.handyman,
        ),

      // Skills raciales (separadas de las skill proficiencies del personaje)
      if (vm.racialSkillProfFromTraits.isNotEmpty)
        _buildProficiencyTag(
          "Racial Skills",
          vm.racialSkillProfFromTraits,
          Colors.teal,
          Icons.auto_awesome,
        ),
    ],
  );
}

Widget _buildProficiencyTag(
    String label, List<String> items, Color color, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((p) => Chip(
            label: Text(p, style: const TextStyle(fontSize: 12, color: Colors.white)),
            backgroundColor: color.withOpacity(0.75),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          )).toList(),
        ),
      ],
    ),
  );
}

Widget _buildLanguagesSection(CreateCharacterViewModel vm) {
  final fixedLangs = vm.totalFixedLanguages;
  final bgChooseCount = vm.languagesToChooseFromBackground;
  final racialChooseCount = vm.racialLanguagesToChoose;
  final selectedBg = vm.selectedBgLanguages;
  final selectedRacial = vm.selectedRacialLanguages;

  // Idiomas ya tomados para deshabilitar en dropdowns
  List<String> allTaken(int currentIdx, List<String> currentSelected) => [
    ...fixedLangs,
    ...currentSelected.asMap().entries
        .where((e) => e.key != currentIdx)
        .map((e) => e.value),
  ];

  // Opciones disponibles del ViewModel (excluye los fijos)
  final available = vm.availableLanguages
      .where((l) => !fixedLangs.contains(l))
      .toList();

  final hasAnything = fixedLangs.isNotEmpty ||
      bgChooseCount > 0 ||
      racialChooseCount > 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle("Languages"),

      if (!hasAnything)
        const Text(
          "Select a race and background to see languages.",
          style: TextStyle(color: Colors.grey),
        ),

      // ── Idiomas fijos (chips limpios) ───────────────
      if (fixedLangs.isNotEmpty) ...[
        const _SubSectionTitle("Known Languages"),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: fixedLangs.map((lang) => Chip(
            label: Text(lang, style: const TextStyle(fontSize: 13)),
            backgroundColor: Colors.blue[50],
            avatar: Icon(Icons.language, size: 14, color: Colors.blue[600]),
          )).toList(),
        ),
        const SizedBox(height: 12),
      ],

      // ── Elecciones del background ────────────────────
      if (bgChooseCount > 0) ...[
        const _SubSectionTitle("Choose from Background"),
        const SizedBox(height: 6),
        ...List.generate(bgChooseCount, (idx) {
          final current = selectedBg.length > idx && selectedBg[idx].isNotEmpty
              ? selectedBg[idx]
              : null;
          final taken = allTaken(idx, selectedBg);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Background Language ${bgChooseCount > 1 ? idx + 1 : ''}",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.translate, size: 18),
              ),
              value: (current != null && available.contains(current))
                  ? current
                  : null,
              items: available.map((lang) {
                final disabled = taken.contains(lang) && lang != current;
                return DropdownMenuItem(
                  value: lang,
                  enabled: !disabled,
                  child: Text(lang,
                      style: TextStyle(
                          color: disabled ? Colors.grey : Colors.black)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                final updated = List<String>.from(selectedBg);
                while (updated.length <= idx) updated.add('');
                updated[idx] = val;
                vm.confirmBgLanguages(updated);
              },
            ),
          );
        }),
      ],

      // ── Elecciones raciales (Half-Elf, Human, etc.) ──
      if (racialChooseCount > 0) ...[
        const _SubSectionTitle("Choose from Race"),
        const SizedBox(height: 6),
        ...List.generate(racialChooseCount, (idx) {
          final current = selectedRacial.length > idx && selectedRacial[idx].isNotEmpty
              ? selectedRacial[idx]
              : null;
          final taken = allTaken(idx, selectedRacial);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Racial Bonus Language",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.auto_awesome, size: 18),
              ),
              value: (current != null && available.contains(current))
                  ? current
                  : null,
              items: available.map((lang) {
                final disabled = taken.contains(lang) && lang != current;
                return DropdownMenuItem(
                  value: lang,
                  enabled: !disabled,
                  child: Text(lang,
                      style: TextStyle(
                          color: disabled ? Colors.grey : Colors.black)),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                final updated = List<String>.from(selectedRacial);
                while (updated.length <= idx) updated.add('');
                updated[idx] = val;
                vm.confirmRacialLanguages(updated);
              },
            ),
          );
        }),
      ],
    ],
  );
}

Widget _sectionTitle(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    title,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
);
