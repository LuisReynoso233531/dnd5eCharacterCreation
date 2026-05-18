import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../views/create_character/dialogs/stats_dialogs.dart';

class LevelAndRollCard extends StatelessWidget {
  const LevelAndRollCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Character Level", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: vm.level,
                  items: List.generate(20, (i) => i + 1)
                      .map((l) => DropdownMenuItem(value: l, child: Text("Lvl $l")))
                      .toList(),
                  onChanged: (val) => vm.updateLevel(val!),
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => StatsDialogs.showConfirmRoll(context, vm),
                icon: const Icon(Icons.casino, color: Colors.red),
                label: const Text("Roll Random Stats (4d6 drop lowest)"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}