import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../tools/dice_roller_view.dart';
import '../tools/hp_tracker_view.dart';
import '../tools/notes_view.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolCard(
            context,
            title: 'Dice Roller',
            subtitle: 'Roll d4, d6, d8, d10, d12, d20, and d100',
            icon: Icons.casino,
            color: context.dndColors.info,
            destination: const DiceRollerView(),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            title: 'HP Tracker',
            subtitle: 'Manage Current, Max, and Temporary Hit Points',
            icon: Icons.favorite,
            color: context.dndColors.danger,
            destination: const HpTrackerView(),
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            title: 'Notes',
            subtitle: 'Keep track of campaign logs, NPCs, and quests',
            icon: Icons.note_alt,
            color: context.dndColors.warning,
            destination: const NotesView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.16),
          radius: 24,
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: context.dndColors.mutedText,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.dndColors.subtleText,
        ),
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
