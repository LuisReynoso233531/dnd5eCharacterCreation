import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character_view_model.dart';

class CharacterTab extends StatelessWidget {
  const CharacterTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Character")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search characters...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              
            ),
          ),
          if (vm.isLoading) const LinearProgressIndicator(),
          const Expanded(
            child: Center(child: Text("Search for a character above")),
          ),
        ],
      ),
    );
  }
}