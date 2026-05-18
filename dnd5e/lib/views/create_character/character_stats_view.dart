import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../utils/app_theme.dart';
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
        title: const Text("Ability Scores"),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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