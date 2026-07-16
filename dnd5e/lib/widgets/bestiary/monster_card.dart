import 'package:flutter/material.dart';

import '../../data/models/monster_model.dart';
import '../../utils/app_theme.dart';

class MonsterCard extends StatelessWidget {
  final MonsterModel monster;

  const MonsterCard({super.key, required this.monster});

  Color _getTypeColor(String type, bool isDark) {
    final t = type.toLowerCase();
    if (t.contains('dragon')) {
      return isDark ? const Color(0xFFFF8A86) : Colors.red.shade700;
    }
    if (t.contains('undead')) {
      return isDark ? const Color(0xFFD8A7FF) : Colors.purple.shade800;
    }
    if (t.contains('fiend')) {
      return isDark ? const Color(0xFFFFA07A) : Colors.deepOrange.shade800;
    }
    if (t.contains('beast')) {
      return isDark ? const Color(0xFFD7B899) : Colors.brown.shade600;
    }
    if (t.contains('aberration')) {
      return isDark ? const Color(0xFFC7A4FF) : Colors.deepPurple;
    }
    if (t.contains('celestial')) {
      return isDark ? const Color(0xFFFFD36D) : Colors.amber.shade700;
    }
    if (t.contains('construct')) {
      return isDark ? const Color(0xFFB5C5CF) : Colors.blueGrey;
    }
    return isDark ? const Color(0xFF7DDBD0) : Colors.teal.shade700;
  }

  String _getMod(int score) {
    final mod = ((score - 10) / 2).floor();
    return mod >= 0 ? '+$mod' : '$mod';
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getTypeColor(monster.type, context.isDarkMode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.dndColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dndColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: Text(
                'CR\n${monster.challengeRating}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ),
          title: Text(
            monster.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '${monster.size} ${monster.type}, ${monster.alignment}',
            style: TextStyle(
              fontSize: 11,
              color: context.dndColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickStat(context, Icons.shield, 'AC ${monster.armorClass}', accent),
                _quickStat(context, Icons.favorite, 'HP ${monster.hitPoints}', accent),
                _quickStat(context, Icons.casino, monster.hitDice, accent),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: context.dndColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBox(context, 'STR', monster.strength),
                  _statBox(context, 'DEX', monster.dexterity),
                  _statBox(context, 'CON', monster.constitution),
                  _statBox(context, 'INT', monster.intelligence),
                  _statBox(context, 'WIS', monster.wisdom),
                  _statBox(context, 'CHA', monster.charisma),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(
              context,
              'Vulnerabilities',
              monster.damageVulnerabilities,
              context.dndColors.danger,
            ),
            _infoRow(context, 'Resistances', monster.damageResistances),
            _infoRow(context, 'Immunities', monster.damageImmunities),
            _infoRow(
              context,
              'Condition Immunities',
              monster.conditionImmunities,
            ),
            _infoRow(context, 'Senses', monster.senses),
            _infoRow(context, 'Languages', monster.languages),
            const SizedBox(height: 8),
            if (monster.specialAbilities.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Traits', accent),
              _buildActionList(context, monster.specialAbilities),
            ],
            if (monster.actions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Actions', accent),
              _buildActionList(context, monster.actions),
            ],
            if (monster.bonusActions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Bonus Actions', accent),
              _buildActionList(context, monster.bonusActions),
            ],
            if (monster.reactions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Reactions', accent),
              _buildActionList(context, monster.reactions),
            ],
            if (monster.legendaryActions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Legendary Actions', accent),
              if (monster.legendaryDesc.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    monster.legendaryDesc,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: context.dndColors.mutedText,
                    ),
                  ),
                ),
              _buildActionList(context, monster.legendaryActions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _quickStat(
    BuildContext context,
    IconData icon,
    String label,
    Color accent,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _statBox(BuildContext context, String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: context.dndColors.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Text(
          '(${_getMod(score)})',
          style: TextStyle(fontSize: 11, color: context.dndColors.mutedText),
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    String title,
    String value, [
    Color? valueColor,
  ]) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: context.colors.onSurface),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor ?? context.dndColors.mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionList(BuildContext context, List<dynamic> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurface,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '${item['name']}. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(text: item['desc']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
