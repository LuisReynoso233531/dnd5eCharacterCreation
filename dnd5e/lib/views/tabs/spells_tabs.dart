import 'package:dnd5e/data/models/spell_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/spell/spells_view_model.dart';
import '../../widgets/create_character_view/spell_selection_view.dart/spell_card.dart';

class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpellsViewModel>();
    const tabTitles = [
      'Cantrips',
      'Level 1',
      'Level 2',
      'Level 3',
      'Level 4',
      'Level 5',
      'Level 6',
      'Level 7',
      'Level 8',
      'Level 9',
    ];

    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spell Compendium'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Cantrips'),
              Tab(text: 'Level 1'),
              Tab(text: 'Level 2'),
              Tab(text: 'Level 3'),
              Tab(text: 'Level 4'),
              Tab(text: 'Level 5'),
              Tab(text: 'Level 6'),
              Tab(text: 'Level 7'),
              Tab(text: 'Level 8'),
              Tab(text: 'Level 9'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: TextField(
                onChanged: vm.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search spells...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(tabTitles.length, (index) {
                  final spellsForTab = vm.filteredSpells.where((spell) {
                    final levelText =
                        (spell['level'] ?? '').toString().toLowerCase();
                    if (index == 0) return levelText.contains('cantrip');
                    return levelText.contains('${index}st') ||
                        levelText.contains('${index}nd') ||
                        levelText.contains('${index}rd') ||
                        levelText.contains('${index}th');
                  }).toList();

                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (spellsForTab.isEmpty) {
                    return const Center(child: Text('No spells found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                    itemCount: spellsForTab.length,
                    itemBuilder: (context, i) {
                      final rawSpell =
                          Map<String, dynamic>.from(spellsForTab[i]);
                      return SpellCard(
                        spell: SpellModel.fromJson(rawSpell),
                        isCompendiumMode: true,
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
