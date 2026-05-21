import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // NECESARIO para context.read()
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../view_models/character/character_subclass_view_model.dart'; // IMPORTANTE
import '../../../../view_models/character/character_view_model.dart'; // IMPORTANTE
import '../../../../utils/app_theme.dart';

Widget archetypeCard(
  BuildContext context, {
  required Map<String, dynamic> arch,
  required DetailClassViewModel dvm,
  required bool canChoose,
}) {
  final selSlug = dvm.selectedArchetype?['slug'] ?? '';
  final isSelected = selSlug.isNotEmpty && selSlug == arch['slug'];
  final name = arch['name'] ?? '';
  final desc = (arch['desc'] ?? '').toString();
  final dotIdx = desc.indexOf('.');
  final shortDesc = dotIdx > 0 && dotIdx < 150
      ? desc.substring(0, dotIdx + 1)
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

  return GestureDetector(
    onTap: handleSelection, // <-- Se actualizó para usar el nuevo método
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryRed.withOpacity(0.06)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.primaryRed : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: isSelected
                ? AppTheme.primaryRed
                : Colors.grey.shade100,
            child: Icon(
              isSelected ? Icons.check : Icons.shield_outlined,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryRed : Colors.black87,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            shortDesc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                        ? Colors.grey
                        : AppTheme.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: handleSelection, // <-- EL BOTÓN AHORA TAMBIÉN USA EL NUEVO MÉTODO
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