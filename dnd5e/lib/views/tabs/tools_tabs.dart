import 'package:flutter/material.dart';
 import '../../views/tools/hp_tracker_view.dart';
 import '../../views/tools/dice_roller_view.dart';
 import '../../views/tools/notes_view.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Tools"),
        backgroundColor: const Color(0xFFD32F2F), // Rojo temático
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildToolCard(
              context,
              title: "Dice Roller",
              subtitle: "Roll d4, d6, d8, d10, d12, d20, and d100",
              icon: Icons.casino,
              color: Colors.blue.shade700,
              destination: const DiceRollerView(),
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              context,
              title: "HP Tracker",
              subtitle: "Manage Current, Max, and Temporary Hit Points",
              icon: Icons.favorite,
              color: Colors.red.shade700,
              destination: const HpTrackerView(), // La que desarrollaremos primero
            ),
            const SizedBox(height: 12),
            _buildToolCard(
              context,
              title: "Notes",
              subtitle: "Keep track of campaign logs, NPCs, and quests",
              icon: Icons.note_alt,
              color: Colors.amber.shade800,
              destination: const NotesView(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para crear botones tipo Tarjeta elegantes
  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          radius: 24,
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
      ),
    );
  }
}