import 'package:flutter/material.dart';
import '../../data/models/monster_model.dart';

class MonsterCard extends StatelessWidget {
  final MonsterModel monster;

  const MonsterCard({super.key, required this.monster});

  Color _getTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('dragon')) return Colors.red.shade700;
    if (t.contains('undead')) return Colors.purple.shade900;
    if (t.contains('fiend')) return Colors.deepOrange.shade800;
    if (t.contains('beast')) return Colors.brown.shade600;
    if (t.contains('aberration')) return Colors.deepPurple;
    if (t.contains('celestial')) return Colors.amber.shade600;
    if (t.contains('construct')) return Colors.blueGrey;
    return Colors.teal.shade700;
  }

  // Calcula el modificador estilo D&D, ej: 16 -> +3
  String _getMod(int score) {
    final mod = ((score - 10) / 2).floor();
    return mod >= 0 ? '+$mod' : '$mod';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(monster.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'CR\n${monster.challengeRating}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
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
            style: const TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            const Divider(height: 20),
            
            // ── Bloque Superior (AC, HP, Velocidad) ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quickStat(Icons.shield, 'AC ${monster.armorClass}', color),
                _quickStat(Icons.favorite, 'HP ${monster.hitPoints}', color),
                _quickStat(Icons.casino, monster.hitDice, color),
              ],
            ),
            const SizedBox(height: 12),

            // ── Puntuaciones de Atributos (STR, DEX, CON, INT, WIS, CHA) ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: color.withOpacity(0.3), width: 1.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBox('STR', monster.strength),
                  _statBox('DEX', monster.dexterity),
                  _statBox('CON', monster.constitution),
                  _statBox('INT', monster.intelligence),
                  _statBox('WIS', monster.wisdom),
                  _statBox('CHA', monster.charisma),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Defensas y Sentidos ──
            _infoRow('Vulnerabilities', monster.damageVulnerabilities, Colors.red.shade700),
            _infoRow('Resistances', monster.damageResistances, Colors.black87),
            _infoRow('Immunities', monster.damageImmunities, Colors.black87),
            _infoRow('Condition Immunities', monster.conditionImmunities, Colors.black87),
            _infoRow('Senses', monster.senses, Colors.black87),
            _infoRow('Languages', monster.languages, Colors.black87),
            
            const SizedBox(height: 8),

            // ── Rasgos Especiales (Traits) ──
            if (monster.specialAbilities.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Traits', color),
              _buildActionList(monster.specialAbilities),
            ],

            // ── Acciones (Actions) ──
            if (monster.actions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Actions', color),
              _buildActionList(monster.actions),
            ],

            // ── Acciones Adicionales (Bonus Actions) ──
            if (monster.bonusActions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Bonus Actions', color),
              _buildActionList(monster.bonusActions),
            ],

            // ── Reacciones (Reactions) ──
            if (monster.reactions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Reactions', color),
              _buildActionList(monster.reactions),
            ],

            // ── Acciones Legendarias (Legendary Actions) ──
            if (monster.legendaryActions.isNotEmpty) ...[
              const Divider(),
              _sectionTitle('Legendary Actions', color),
              if (monster.legendaryDesc.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    monster.legendaryDesc,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                  ),
                ),
              _buildActionList(monster.legendaryActions),
            ],
          ],
        ),
      ),
    );
  }

  // Widget para (AC, HP, Dados)
  Widget _quickStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  // Widget para STR, DEX, CON...
  Widget _statBox(String label, int score) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 2),
        Text('$score', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text('(${_getMod(score)})', style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  // Filas para Inmunidades, Resistencias, etc.
  Widget _infoRow(String title, String value, Color valueColor) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Colors.black87),
          children: [
            TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: valueColor)),
          ],
        ),
      ),
    );
  }

  // Título de Sección estilizado
  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }

  // Iterador para imprimir listas de acciones
  Widget _buildActionList(List<dynamic> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              children: [
                TextSpan(text: '${item['name']}. ', style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                TextSpan(text: item['desc']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}