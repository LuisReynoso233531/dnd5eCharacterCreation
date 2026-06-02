import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/bestiary/bestiary_view_model.dart';
import '../../data/models/monster_model.dart';
import '../../widgets/bestiary/monster_card.dart'; // Importa tu nueva tarjeta

class BestiaryTab extends StatelessWidget {
  const BestiaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BestiaryViewModel>();

    // Categorías oficiales de monstruos en D&D 5e
    final List<String> tabTitles = [
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Bestiary"),
          backgroundColor: const Color(0xFFD32F2F), // Mismo rojo del compendio
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: tabTitles.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val) => vm.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search creatures by name...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: List.generate(tabTitles.length, (index) {
                  final currentTabType = tabTitles[index].toLowerCase();

                  // Filtrar por la pestaña seleccionada
                  final monstersForTab = vm.filteredMonsters.where((monster) {
                    if (index == 0) return true; // 'All' tab muestra todo
                    final typeText = (monster['type'] ?? '')
                        .toString()
                        .toLowerCase();
                    return typeText.contains(currentTabType);
                  }).toList();

                  if (monstersForTab.isEmpty && !vm.isLoading) {
                    return const Center(
                      child: Text('No creatures found in this category.'),
                    );
                  }

                  if (vm.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFD32F2F),
                      ),
                    );
                  }

                  if (vm.errorMessage != null && index == 0) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(vm.errorMessage!, textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  vm.fetchMonsters(), // Botón para reintentar
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    itemCount: monstersForTab.length,
                    itemBuilder: (context, i) {
                      // Parseamos el mapa json al Modelo
                      final monsterModel = MonsterModel.fromJson(
                        monstersForTab[i],
                      );

                      return MonsterCard(monster: monsterModel);
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
