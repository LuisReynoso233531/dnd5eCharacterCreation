import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../../view_models/character/character_view_model.dart';
import 'character_stats_view.dart';

class ClassSelectionView extends StatefulWidget {
  const ClassSelectionView({super.key});

  @override
  State<ClassSelectionView> createState() => _ClassSelectionViewState();
}

class _ClassSelectionViewState extends State<ClassSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CreateCharacterViewModel>().fetchAvailableClasses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your class')),
      body: Column(
        children: [
          if (vm.selectedRace != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.dndColors.surfaceMuted,
                border: Border(
                  bottom: BorderSide(color: context.dndColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_moon_outlined,
                    color: context.colors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Race: ${vm.selectedRace!['name']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Speed: ${vm.speed} ft. | Bonuses: ${vm.racialBonuses.isEmpty ? 'None' : vm.racialBonuses.entries.map((entry) => '${entry.key} +${entry.value}').join(', ')}",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.dndColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: vm.classes.length,
                    itemBuilder: (context, index) {
                      final charClass = vm.classes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              vm.selectClass(charClass);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CharacterStatsView(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: context.dndColors.dangerContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.water_drop,
                                      color: context.dndColors.danger,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          charClass.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          children: [
                                            _buildClassInfo(
                                              context,
                                              Icons.favorite,
                                              'Hit Die: ${charClass.hit_dice}',
                                              context.dndColors.danger,
                                            ),
                                            _buildClassInfo(
                                              context,
                                              Icons.auto_fix_high,
                                              'Saves: ${charClass.prof_saving_throws}',
                                              context.dndColors.info,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: context.dndColors.subtleText,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildClassInfo(
  BuildContext context,
  IconData icon,
  String text,
  Color color,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: context.dndColors.mutedText),
        ),
      ),
    ],
  );
}
