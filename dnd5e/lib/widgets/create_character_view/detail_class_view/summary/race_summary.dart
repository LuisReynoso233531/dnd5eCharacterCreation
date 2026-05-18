import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/character/character_view_model.dart';
import 'hint.dart';
import 'trait_block.dart';

class RaceTraitsSummary extends StatefulWidget {
  const RaceTraitsSummary({super.key});

  @override
  State<RaceTraitsSummary> createState() => _RaceTraitsSummaryState();
}

class _RaceTraitsSummaryState extends State<RaceTraitsSummary> {
  bool _isExpanded = false; // El estado vive aquí adentro ahora

  @override
  Widget build(BuildContext context) {
    // Escucha el ViewModel directamente
    final vm = context.watch<CreateCharacterViewModel>();
    final race = vm.selectedRace;

    if (race == null) {
      return hint('Select a race to see racial traits.');
    }

    return traitBlock(
      title: '${race['name']} — Racial Traits',
      icon: Icons.face,
      color: Colors.teal,
      raw: vm.getCleanedRaceTraits(),
      expanded: _isExpanded,
      onToggle: () => setState(() => _isExpanded = !_isExpanded),
    );
  }
}
