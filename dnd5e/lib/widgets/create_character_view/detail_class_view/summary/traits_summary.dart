import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/character/character_view_model.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import 'trait_block.dart';
import '../../../../utils/app_theme.dart';

class ClassTraitsSummary extends StatefulWidget {
  final dynamic cls;

  const ClassTraitsSummary({super.key, required this.cls});

  @override
  State<ClassTraitsSummary> createState() => _ClassTraitsSummaryState();
}

class _ClassTraitsSummaryState extends State<ClassTraitsSummary> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Escuchamos los ViewModels directamente desde el contexto interno
    final vm = context.watch<CreateCharacterViewModel>();
    final dvm = context.watch<DetailClassViewModel>();
    final cls = widget.cls;

    final buf = StringBuffer();

    // 1. Información Base (Vida y Salvaciones)
    final hpFirst = cls.hp_at_1st_level ?? '';
    final hpHigher = cls.hp_at_higher_levels ?? '';
    final saving = cls.prof_saving_throws ?? '';

    if (hpFirst.isNotEmpty) buf.writeln('HP at 1st Level:\n$hpFirst\n');
    if (hpHigher.isNotEmpty) buf.writeln('HP at Higher Levels:\n$hpHigher\n');
    if (saving.isNotEmpty) buf.writeln('Saving Throws:\n$saving\n');

    // 2. Procesamiento de Rasgos (Traits) desbloqueados
    final unlockedFeatures = dvm.getUnlockedFeatures(cls, vm.level);
    final availableStyles = dvm.getAvailableFightingStyles(cls, vm.level);
    final hasFightingStyle = availableStyles.isNotEmpty;

    if (unlockedFeatures.isNotEmpty) {
      buf.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('UNLOCKED TRAITS (Level ${vm.level})\n');

      for (final feat in unlockedFeatures) {
        final titleLower = feat['title']!.toLowerCase();

        // Caso Especial - Fighting Style: sustituir por la elección del usuario
        if (titleLower == 'fighting style' && hasFightingStyle) {
          if (dvm.selectedFightingStyleName != null) {
            final styleData = availableStyles.firstWhere(
              (s) => s['name'] == dvm.selectedFightingStyleName,
              orElse: () => {
                'name': dvm.selectedFightingStyleName!,
                'desc': '',
              },
            );
            buf.writeln('FIGHTING STYLE: ${styleData['name']!.toUpperCase()}');
            if ((styleData['desc'] ?? '').isNotEmpty) {
              buf.writeln('${styleData['desc']}\n');
            }
          } else {
            buf.writeln('FIGHTING STYLE');
            buf.writeln('(Select a fighting style in the section above)\n');
          }
          continue; // Omitir la descripción genérica del JSON
        }

        buf.writeln(feat['title']!.toUpperCase());
        buf.writeln('${feat['desc']}\n');
      }
    } else {
      buf.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('No specific traits unlocked at this level yet.');
    }

    // 3. Retornamos tu componente visual original adaptado al nuevo estado
    return traitBlock(
      title: '${cls.name} — Class Features',
      icon: Icons.military_tech,
      color: context.colors.primary,
      raw: buf.toString().trim(),
      expanded: _isExpanded,
      onToggle: () => setState(() => _isExpanded = !_isExpanded),
    );
  }
}
