import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
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
          child: Text(
            'Level Up Improvements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...vm.availableImprovementLevels.map(
          (level) => _ImprovementTile(level: level),
        ),
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
    final pending = choice == null;
    final subtitle = pending
        ? 'Pending selection'
        : choice['type'] == 'feat'
            ? "Feat: ${choice['data']['name']}"
            : 'Points assigned';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          'Level $level Improvement',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: pending
                ? context.dndColors.warning
                : context.dndColors.success,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Select Improvement Type:'),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Points (+2)'),
                      selected: choice?['type'] == 'points',
                      onSelected: (_) => StatsDialogs.showPointsDialog(
                        context,
                        vm,
                        level,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Feat'),
                      selected: choice?['type'] == 'feat',
                      onSelected: (_) => StatsDialogs.showFeatsDialog(
                        context,
                        vm,
                        level,
                      ),
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
