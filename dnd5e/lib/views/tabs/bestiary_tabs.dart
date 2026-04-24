import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/bestiary/bestiary_view_model.dart';

class BestiaryTab extends StatelessWidget {
  const BestiaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BestiaryViewModel>();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Bestiary")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search creatures...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              
            ),
          ),
          if (vm.isLoading) const LinearProgressIndicator(),
          const Expanded(
            child: Center(child: Text("Search for a creature above")),
          ),
        ],
      ),
    );
  }
}