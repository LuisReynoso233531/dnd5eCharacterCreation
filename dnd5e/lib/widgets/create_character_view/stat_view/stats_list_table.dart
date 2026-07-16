import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../utils/app_theme.dart';

class StatsListTable extends StatelessWidget {
  const StatsListTable({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ['Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma'];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) => StatRow(statName: stats[index]),
    );
  }
}

class StatRow extends StatelessWidget {
  final String statName;
  const StatRow({super.key, required this.statName});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final int base = vm.baseStats[statName]!;
    final int racialBonus = vm.racialBonuses[statName] ?? 0;
    final int total = vm.getTotalStat(statName);
    final int mod = vm.getModifier(statName);

    final int improvementBonus = _calculateImprovementBonus(vm);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: improvementBonus > 0
            ? context.dndColors.warningContainer
            : context.dndColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: improvementBonus > 0
              ? context.dndColors.warning
              : context.dndColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(statName, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: base > 0 ? () => vm.updateBaseStat(statName, base - 1) : null,
                ),
                Text("$base", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: base < 20 ? () => vm.updateBaseStat(statName, base + 1) : null,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Total: $total", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Mod: ${mod >= 0 ? '+' : ''}$mod", style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold)),
                if (racialBonus > 0)
                  Text("Race: +$racialBonus", style: TextStyle(fontSize: 10, color: context.dndColors.success)),
                if (improvementBonus > 0)
                  Text("Lvl Up: +$improvementBonus", style: TextStyle(fontSize: 10, color: context.dndColors.warning, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateImprovementBonus(CreateCharacterViewModel vm) {
    int bonus = 0;
    vm.levelUpChoices.forEach((lvl, choice) {
      if (lvl <= vm.level) {
        if (choice['type'] == 'points') {
          bonus += (Map<String, int>.from(choice['data'])[statName] ?? 0);
        }
        if (choice['type'] == 'feat') {
          final desc = (choice['data']['desc'] ?? '').toString().toLowerCase();
          final s = statName.toLowerCase();
          if (RegExp('increase your $s (score )?by 1|$s increases by 1', caseSensitive: false).hasMatch(desc)) {
            bonus += 1;
          }
        }
      }
    });
    return bonus;
  }
}