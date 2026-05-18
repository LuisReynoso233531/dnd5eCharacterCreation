import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../views/create_character/dialogs/stats_dialogs.dart';

class LevelUpImprovementsSection extends StatelessWidget {
  const LevelUpImprovementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Level Up Improvements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...vm.availableImprovementLevels.map((lvl) => _ImprovementTile(level: lvl)),
      ],
    );
  }
}

class _ImprovementTile extends StatelessWidget {
  final int level;
  const _ImprovementTile({required this.level});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final choice = vm.levelUpChoices[level];
    
    String title = "Level $level Improvement";
    String subtitle = choice == null
        ? "Pending selection"
        : (choice['type'] == 'feat' ? "Feat: ${choice['data']['name']}" : "Points assigned");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: choice == null ? Colors.orange : Colors.green)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Select Improvement Type:"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Points (+2)"),
                      selected: choice?['type'] == 'points',
                      onSelected: (selected) => StatsDialogs.showPointsDialog(context, vm, level),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Feat"),
                      selected: choice?['type'] == 'feat',
                      onSelected: (selected) => StatsDialogs.showFeatsDialog(context, vm, level),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}