import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/spell/spells_view_model.dart';
import 'package:dnd5e/data/models/spell_model.dart'; 
import '../../widgets/create_character_view/spell_selection_view.dart/spell_card.dart'; 

class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpellsViewModel>();
    
    final List<String> tabTitles = [
      'Cantrips', 'Level 1', 'Level 2', 'Level 3', 'Level 4', 
      'Level 5', 'Level 6', 'Level 7', 'Level 8', 'Level 9'
    ];

    return DefaultTabController(
      length: tabTitles.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Spell Compendium"),
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: tabTitles.map((t) => Tab(text: t)).toList(),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (val) => vm.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search spells...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: List.generate(tabTitles.length, (index) {
                  final spellsForTab = vm.filteredSpells.where((spell) {
                    final levelText = (spell['level'] ?? '').toString().toLowerCase();
                    if (index == 0) return levelText.contains('cantrip');
                    return levelText.contains('${index}st') || 
                           levelText.contains('${index}nd') || 
                           levelText.contains('${index}rd') || 
                           levelText.contains('${index}th');
                  }).toList();

                  if (spellsForTab.isEmpty && !vm.isLoading) {
                    return const Center(child: Text('No spells found.'));
                  }

                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: spellsForTab.length,
                    itemBuilder: (context, i) {
                      final Map<String, dynamic> rawSpell = spellsForTab[i];
                      final spellModel = SpellModel.fromJson(rawSpell);

                      return SpellCard(
                        spell: spellModel,      
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