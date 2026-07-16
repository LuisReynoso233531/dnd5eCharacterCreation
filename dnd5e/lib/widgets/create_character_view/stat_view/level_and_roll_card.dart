import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_theme.dart';
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
                const Text(
                  'Character Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: vm.level,
                  items: List.generate(20, (index) => index + 1)
                      .map(
                        (level) => DropdownMenuItem<int>(
                          value: level,
                          child: Text('Lvl $level'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) vm.updateLevel(value);
                  },
                ),
              ],
            ),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => StatsDialogs.showConfirmRoll(context, vm),
                icon: const Icon(Icons.casino),
                label: const Text('Roll Random Stats (4d6 drop lowest)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
