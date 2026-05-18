import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/character/character_view_model.dart';
import 'hint.dart';
import 'trait_block.dart';

class BackgroundTraitsSummary extends StatefulWidget {
  const BackgroundTraitsSummary({super.key});

  @override
  State<BackgroundTraitsSummary> createState() =>
      _BackgroundTraitsSummaryState();
}

class _BackgroundTraitsSummaryState extends State<BackgroundTraitsSummary> {
  bool _isExpanded = false; // El estado vive aquí adentro ahora

  @override
  Widget build(BuildContext context) {
    // Escucha el ViewModel directamente
    final vm = context.watch<CreateCharacterViewModel>();
    final bg = vm.selectedBackground;

    if (bg == null) {
      return hint('Select a background to see its feature.');
    }

    return traitBlock(
      title: '${bg['name']} — ${bg['feature'] ?? 'Feature'}',
      icon: Icons.history_edu,
      color: Colors.blueGrey,
      raw: bg['feature_desc']?.toString() ?? '',
      expanded: _isExpanded,
      onToggle: () => setState(() => _isExpanded = !_isExpanded),
    );
  }
}
