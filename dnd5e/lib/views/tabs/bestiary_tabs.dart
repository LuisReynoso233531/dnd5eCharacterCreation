import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/monster_model.dart';
import '../../view_models/bestiary/bestiary_view_model.dart';
import '../../widgets/bestiary/monster_card.dart';

class BestiaryTab extends StatelessWidget {
  const BestiaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BestiaryViewModel>();
    const tabTitles = [
      'All',
      'Aberration',
      'Beast',
      'Celestial',
      'Construct',
      'Dragon',
      'Elemental',
      'Fey',
      'Fiend',
      'Giant',
      'Humanoid',
      'Monstrosity',
      'Ooze',
      'Plant',
      'Undead',
    ];

    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bestiary'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Aberration'),
              Tab(text: 'Beast'),
              Tab(text: 'Celestial'),
              Tab(text: 'Construct'),
              Tab(text: 'Dragon'),
              Tab(text: 'Elemental'),
              Tab(text: 'Fey'),
              Tab(text: 'Fiend'),
              Tab(text: 'Giant'),
              Tab(text: 'Humanoid'),
              Tab(text: 'Monstrosity'),
              Tab(text: 'Ooze'),
              Tab(text: 'Plant'),
              Tab(text: 'Undead'),
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
                  hintText: 'Search creatures by name...',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: List.generate(tabTitles.length, (index) {
                  final currentType = tabTitles[index].toLowerCase();
                  final monstersForTab = vm.filteredMonsters.where((monster) {
                    if (index == 0) return true;
                    return (monster['type'] ?? '')
                        .toString()
                        .toLowerCase()
                        .contains(currentType);
                  }).toList();

                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null && index == 0) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              vm.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: vm.fetchMonsters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (monstersForTab.isEmpty) {
                    return const Center(
                      child: Text('No creatures found in this category.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                    itemCount: monstersForTab.length,
                    itemBuilder: (context, i) {
                      return MonsterCard(
                        monster: MonsterModel.fromJson(monstersForTab[i]),
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
