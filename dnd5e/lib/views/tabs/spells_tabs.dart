import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/spell/spells_view_model.dart';

class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SpellsViewModel>();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Spellbook")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search spells...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: vm.onSearchChanged,
            ),
          ),
          if (vm.isLoading) const LinearProgressIndicator(),
          const Expanded(
            child: Center(child: Text("Search for a spell above")),
          ),
        ],
      ),
    );
  }
}