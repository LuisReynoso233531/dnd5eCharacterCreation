import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../utils/app_theme.dart';

class StatsDialogs {
  static void showConfirmRoll(BuildContext context, CreateCharacterViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Roll Random Stats?"),
        content: const Text("This will replace your current base statistics. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.rollRandomStats();
              Navigator.pop(context);
            },
            child: const Text("Roll Dice!", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void showPointsDialog(BuildContext context, CreateCharacterViewModel vm, int level) {
    String? firstStat;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("ASI: Choose Points"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Option 1: +2 to one stat"),
              Wrap(
                children: vm.baseStats.keys.map((s) => TextButton(
                  onPressed: () {
                    vm.setLevelChoice(level, 'points', {s: 2});
                    Navigator.pop(context);
                  },
                  child: Text("+2 $s"),
                )).toList(),
              ),
              const Divider(),
              const Text("Option 2: +1 to two stats"),
              Text(firstStat == null ? "Select first stat" : "First: $firstStat. Select second:"),
              Wrap(
                children: vm.baseStats.keys.map((s) => TextButton(
                  onPressed: firstStat == s ? null : () {
                    if (firstStat == null) {
                      setState(() => firstStat = s);
                    } else {
                      vm.setLevelChoice(level, 'points', {firstStat!: 1, s: 1});
                      Navigator.pop(context);
                    }
                  },
                  child: Text("+1 $s"),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showFeatsDialog(BuildContext context, CreateCharacterViewModel vm, int level) {
    vm.loadFeatsIfNeeded();
    showDialog(
      context: context,
      builder: (context) => Consumer<CreateCharacterViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const AlertDialog(
              content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
            );
          }

          final validFeats = vm.allFeats.where((f) => vm.canTakeFeat(f)).toList();

          return AlertDialog(
            title: Text("Select Feat for Level $level"),
            content: SizedBox(
              width: double.maxFinite,
              child: validFeats.isEmpty
                  ? const Text("No cumples los requisitos para ninguna dote.")
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: validFeats.length,
                      itemBuilder: (context, i) {
                        final feat = validFeats[i];
                        return Card(
                          child: ListTile(
                            title: Text(feat['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(feat['prerequisite'] ?? "No requisites", style: const TextStyle(color: Colors.red, fontSize: 11)),
                            onTap: () {
                              Navigator.pop(context);
                              final statChoice = _detectStatChoice(feat);
                              if (statChoice != null) {
                                _showFeatStatChoiceDialog(context, vm, level, feat, statChoice);
                              } else {
                                vm.setLevelChoice(level, 'feat', feat);
                              }
                            },
                            onLongPress: () => showFeatDetails(context, feat),
                          ),
                        );
                      },
                    ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))],
          );
        },
      ),
    );
  }

  static void showFeatDetails(BuildContext context, Map<String, dynamic> feat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            controller: scrollController,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text(feat['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
              if (feat['prerequisite'] != null) ...[
                const SizedBox(height: 8),
                Text("Requisito: ${feat['prerequisite']}", style: const TextStyle(fontStyle: FontStyle.italic, color: AppTheme.primaryRed)),
              ],
              const Divider(height: 30),
              Text(feat['desc'] ?? "Sin descripción disponible.", style: const TextStyle(fontSize: 16, height: 1.5)),
              const SizedBox(height: 20),
              if (feat['effects_desc'] != null) ...[
                const Text("Effects:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...(feat['effects_desc'] as List).map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [const Text("• "), Expanded(child: Text(e.toString()))],
                  ),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static List<String>? _detectStatChoice(Map<String, dynamic> feat) {
    final effects = (feat['effects_desc'] as List? ?? []);
    final statNames = ['Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma'];

    for (var e in effects) {
      final text = e.toString();
      if (text.toLowerCase().contains(' or ') &&
          (text.toLowerCase().contains('score increases') ||
           text.toLowerCase().contains('score by 1') ||
           text.toLowerCase().contains('attribute by 1'))) {
        final found = statNames.where((s) => text.toLowerCase().contains(s.toLowerCase())).toList();
        if (found.length >= 2) return found;
      }
    }
    return null;
  }

  static void _showFeatStatChoiceDialog(BuildContext context, CreateCharacterViewModel vm, int level, Map<String, dynamic> feat, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${feat['name']}: Choose Stat Bonus"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This feat increases one of the following stats by 1.\nChoose which one to apply:", textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ...options.map((stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red[800], side: BorderSide(color: Colors.red[300]!)),
                  onPressed: () {
                    vm.setLevelChoice(level, 'feat', feat, featChoice: ResolvedFeatChoice(chosenStat: stat));
                    Navigator.pop(context);
                  },
                  child: Text("+1 $stat"),
                ),
              ),
            )),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))],
      ),
    );
  }
}