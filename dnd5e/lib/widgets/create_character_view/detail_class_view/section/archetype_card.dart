import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../view_models/character/character_subclass_view_model.dart';
import '../../../../view_models/character/character_view_model.dart';

Widget archetypeCard(
  BuildContext context, {
  required Map<String, dynamic> arch,
  required DetailClassViewModel dvm,
  required bool canChoose,
}) {
  final selectedSlug = dvm.selectedArchetype?['slug'] ?? '';
  final isSelected = selectedSlug.isNotEmpty && selectedSlug == arch['slug'];
  final name = arch['name'] ?? '';
  final desc = (arch['desc'] ?? '').toString();
  final dotIndex = desc.indexOf('.');
  final shortDesc = dotIndex > 0 && dotIndex < 150
      ? desc.substring(0, dotIndex + 1)
      : desc.length > 110
          ? '${desc.substring(0, 110)}…'
          : desc;

  void handleSelection() {
    if (!canChoose) return;

    final subclassVM = context.read<CharacterSubclassViewModel>();
    final mainVM = context.read<CreateCharacterViewModel>();
    final existingSkills = <String>[
      ...mainVM.skillVM.classFixedSkills,
      ...mainVM.skillVM.bgFixedSkills,
      ...mainVM.skillVM.selectedClassSkills,
    ];

    subclassVM.setArchetype(isSelected ? null : arch, existingSkills);
  }

  final selectedColor = context.colors.primary;

  return GestureDetector(
    onTap: handleSelection,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primaryContainer.withValues(alpha: 0.48)
            : context.dndColors.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? selectedColor : context.dndColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: isSelected
                ? selectedColor
                : context.dndColors.surfaceStrong,
            child: Icon(
              isSelected ? Icons.check : Icons.shield_outlined,
              size: 16,
              color: isSelected
                  ? context.colors.onPrimary
                  : context.dndColors.mutedText,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? selectedColor : context.colors.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            shortDesc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: context.dndColors.mutedText,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            Text(desc, style: const TextStyle(fontSize: 13, height: 1.55)),
            if (canChoose) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? context.dndColors.surfaceStrong
                        : selectedColor,
                    foregroundColor: isSelected
                        ? context.colors.onSurface
                        : context.colors.onPrimary,
                  ),
                  onPressed: handleSelection,
                  icon: Icon(isSelected ? Icons.close : Icons.check, size: 16),
                  label: Text(isSelected ? 'Deselect' : 'Select $name'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
