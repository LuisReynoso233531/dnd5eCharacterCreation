import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../utils/languajes.dart';
import '../../../../view_models/character/character_language_view_model.dart';
import '../section_title.dart';
import '../sub_section_title.dart';

Widget buildLanguagesSection(CharacterLanguageViewModel vm) {
  return Builder(
    builder: (context) {
      final fixedLanguages = vm.totalFixedLanguages;
      final backgroundCount = vm.languagesToChooseFromBackground;
      final racialCount = vm.racialLanguagesToChoose;
      final featCount = vm.languagesToChooseFromFeat;
      final selectedBackground = vm.selectedBgLanguages;
      final selectedRacial = vm.selectedRacialLanguages;
      final selectedFeat = vm.selectedFeatLanguages;
      final available = availableLanguages
          .where((language) => !fixedLanguages.contains(language))
          .toList();
      final hasAnything = fixedLanguages.isNotEmpty ||
          backgroundCount > 0 ||
          racialCount > 0 ||
          featCount > 0;

      List<String> takenFor(String group, int currentIndex) {
        Iterable<String> withoutCurrent(
          String listGroup,
          List<String> values,
        ) {
          return values.asMap().entries.where((entry) {
            return listGroup != group || entry.key != currentIndex;
          }).map((entry) => entry.value);
        }

        return <String>{
          ...fixedLanguages,
          ...withoutCurrent('background', selectedBackground),
          ...withoutCurrent('racial', selectedRacial),
          ...withoutCurrent('feat', selectedFeat),
        }.where((language) => language.isNotEmpty).toList();
      }

      Widget languageDropdown({
        required String group,
        required int index,
        required String label,
        required IconData icon,
        required List<String> selectedValues,
        required ValueChanged<List<String>> onConfirm,
      }) {
        final current = selectedValues.length > index &&
                selectedValues[index].isNotEmpty
            ? selectedValues[index]
            : null;
        final validCurrent = current != null && available.contains(current)
            ? current
            : null;
        final taken = takenFor(group, index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            key: ValueKey('$group-language-$index-$validCurrent'),
            isExpanded: true,
            initialValue: validCurrent,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, size: 18),
            ),
            items: available.map((language) {
              final disabled = taken.contains(language) && language != current;

              return DropdownMenuItem<String>(
                value: language,
                enabled: !disabled,
                child: Text(
                  language,
                  style: TextStyle(
                    color: disabled ? context.dndColors.subtleText : null,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              final updated = List<String>.from(selectedValues);
              while (updated.length <= index) {
                updated.add('');
              }
              updated[index] = value;
              onConfirm(updated);
            },
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Languages'),
          if (!hasAnything)
            Text(
              'Select a race and background to see languages.',
              style: TextStyle(color: context.dndColors.mutedText),
            ),
          if (fixedLanguages.isNotEmpty) ...[
            const SubSectionTitle('Known Languages'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: fixedLanguages
                  .map(
                    (language) => Chip(
                      label: Text(
                        language,
                        style: const TextStyle(fontSize: 13),
                      ),
                      backgroundColor: context.dndColors.infoContainer,
                      avatar: Icon(
                        Icons.language,
                        size: 14,
                        color: context.dndColors.info,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (backgroundCount > 0) ...[
            const SubSectionTitle('Choose from Background'),
            const SizedBox(height: 6),
            ...List.generate(
              backgroundCount,
              (index) => languageDropdown(
                group: 'background',
                index: index,
                label: backgroundCount > 1
                    ? 'Background Language ${index + 1}'
                    : 'Background Language',
                icon: Icons.translate,
                selectedValues: selectedBackground,
                onConfirm: vm.confirmBgLanguages,
              ),
            ),
          ],
          if (racialCount > 0) ...[
            const SubSectionTitle('Choose from Race'),
            const SizedBox(height: 6),
            ...List.generate(
              racialCount,
              (index) => languageDropdown(
                group: 'racial',
                index: index,
                label: racialCount > 1
                    ? 'Racial Bonus Language ${index + 1}'
                    : 'Racial Bonus Language',
                icon: Icons.auto_awesome,
                selectedValues: selectedRacial,
                onConfirm: vm.confirmRacialLanguages,
              ),
            ),
          ],
          if (featCount > 0) ...[
            const SubSectionTitle('Choose from Feat'),
            const SizedBox(height: 6),
            ...List.generate(
              featCount,
              (index) => languageDropdown(
                group: 'feat',
                index: index,
                label: featCount > 1
                    ? 'Feat Language ${index + 1}'
                    : 'Feat Language',
                icon: Icons.stars_outlined,
                selectedValues: selectedFeat,
                onConfirm: vm.confirmFeatLanguages,
              ),
            ),
          ],
        ],
      );
    },
  );
}
