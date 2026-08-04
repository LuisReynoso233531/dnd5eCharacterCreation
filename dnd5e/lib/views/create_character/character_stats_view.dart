import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../widgets/create_character_view/stat_view/level_and_roll_card.dart';
import '../../widgets/create_character_view/stat_view/level_up_improvements.dart';
import '../../widgets/create_character_view/stat_view/stats_bottom_button.dart';
import '../../widgets/create_character_view/stat_view/stats_list_table.dart';

class CharacterStatsView extends StatelessWidget {
  const CharacterStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.isLevelUp ? 'Level Up — Ability Scores' : 'Ability Scores'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vm.isLevelUp) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Updating ${vm.name} from level ${vm.originalLevel} '
                          'to level ${vm.level}. Existing choices are loaded.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const LevelAndRollCard(),
            const SizedBox(height: 20),
            const StatsListTable(),
            const SizedBox(height: 20),

            if (vm.availableImprovementLevels.isNotEmpty) ...[
              const Divider(),
              const LevelUpImprovementsSection(),
            ],

            const SizedBox(height: 30),
            const StatsBottomButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
