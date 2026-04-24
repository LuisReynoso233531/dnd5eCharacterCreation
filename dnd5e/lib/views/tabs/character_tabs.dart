import 'package:flutter/material.dart';
import '../create_character/race_selector_view.dart'; // Crearemos esto ahora

class CharacterTab extends StatelessWidget {
  const CharacterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FILA DE BÚSQUEDA Y CREACIÓN
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RaceSelectionView()),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Create", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search characters...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const Expanded(
              child: Center(child: Text("No characters yet. Tap Create to start!")),
            ),
          ],
        ),
      ),
    );
  }
}