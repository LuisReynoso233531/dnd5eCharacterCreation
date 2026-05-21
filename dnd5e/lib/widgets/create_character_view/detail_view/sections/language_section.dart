import 'package:flutter/material.dart';
import '../../../../view_models/character/character_language_view_model.dart';
import '../../../../utils/languajes.dart';
import '../section_title.dart';
import '../sub_section_title.dart';

Widget buildLanguagesSection(CharacterLanguageViewModel vm) {
  final fixedLangs = vm.totalFixedLanguages;
  final bgChooseCount = vm.languagesToChooseFromBackground;
  final ftChooseCount = vm.languagesToChooseFromFeat;
  final racialChooseCount = vm.racialLanguagesToChoose;
  final selectedBg = vm.selectedBgLanguages;
  final selectedRacial = vm.selectedRacialLanguages;
  final selectedFeat = vm.selectedFeatLanguages;

  // Idiomas ya tomados para deshabilitar en dropdowns
  List<String> allTaken(int currentIdx, List<String> currentSelected) => [
    ...fixedLangs,
    ...currentSelected
        .asMap()
        .entries
        .where((e) => e.key != currentIdx)
        .map((e) => e.value),
        
  ];

  // Opciones disponibles del ViewModel (excluye los fijos)
  final available = availableLanguages
      .where((l) => !fixedLangs.contains(l))
      .toList();

  final hasAnything =
      fixedLangs.isNotEmpty || bgChooseCount > 0 || racialChooseCount > 0 || ftChooseCount > 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Languages"),

      if (!hasAnything)
        const Text(
          "Select a race and background to see languages.",
          style: TextStyle(color: Colors.grey),
        ),

      // ── Idiomas fijos (chips limpios) ───────────────
      if (fixedLangs.isNotEmpty) ...[
        const SubSectionTitle("Known Languages"),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: fixedLangs
              .map(
                (lang) => Chip(
                  label: Text(lang, style: const TextStyle(fontSize: 13)),
                  backgroundColor: Colors.blue[50],
                  avatar: Icon(
                    Icons.language,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
      ],

      // ── Elecciones del background ────────────────────
      if (bgChooseCount > 0) ...[
        const SubSectionTitle("Choose from Background"),
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
                labelText:
                    "Background Language ${bgChooseCount > 1 ? idx + 1 : ''}",
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
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: disabled ? Colors.grey : Colors.black,
                    ),
                  ),
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
        const SubSectionTitle("Choose from Race"),
        const SizedBox(height: 6),
        ...List.generate(racialChooseCount, (idx) {
          final current =
              selectedRacial.length > idx && selectedRacial[idx].isNotEmpty
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
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: disabled ? Colors.grey : Colors.black,
                    ),
                  ),
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
      if (ftChooseCount > 0) ...[
        const SubSectionTitle("Choose from Feat"),
        const SizedBox(height: 6),
        ...List.generate(ftChooseCount, (idx) {
          final current = selectedFeat.length > idx && selectedFeat[idx].isNotEmpty
              ? selectedFeat[idx]
              : null;
          final taken = allTaken(idx, selectedFeat);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText:
                    "Background Language ${bgChooseCount > 1 ? idx + 1 : ''}",
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
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: disabled ? Colors.grey : Colors.black,
                    ),
                  ),
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
    ],
  );
}
