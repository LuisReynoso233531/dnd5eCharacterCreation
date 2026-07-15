import 'package:flutter/material.dart';
import '../../../data/models/spell_model.dart';
import '../../../view_models/character/character_spell_view_model.dart';
import './slots_summary.dart';

Widget magicStatsBar(
  String classSlug,
  String ability,
  int spellMod,
  int attackBonus,
  int saveDC,
  int spellsKnown,
  int totalSelected,
  SpellcastingInfo info,
  CharacterSpellViewModel spellVM,
) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    color: Colors.grey.shade900,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statChip(Icons.auto_fix_high, ability, Colors.purple.shade200),
            _statChip(
              Icons.add_circle_outline,
              '${attackBonus >= 0 ? '+' : ''}$attackBonus Atk',
              Colors.orange.shade200,
            ),
            _statChip(Icons.shield, 'DC $saveDC', Colors.blue.shade200),
            _statChip(
              Icons.menu_book,
              '${spellVM.totalCantripsTowardLimit}/${info.cantripsKnown} cantrips  '
              '${spellVM.totalNonCantripsTowardLimit}/$spellsKnown spells'
              '${spellVM.totalAutomaticSpells > 0 ? ' +${spellVM.totalAutomaticSpells} granted' : ''}',
              Colors.green.shade200,
            ),
          ],
        ),
        const SizedBox(height: 6),
        slotsSummary(classSlug, info),

        // ── Barra de carga progresiva ──────────────────────────────
        if (!spellVM.isFullyLoaded) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spellVM.loadProgress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(Colors.purple.shade300),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(spellVM.loadProgress * 100).toInt()}% spells',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _statChip(IconData icon, String label, Color color) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(icon, size: 13, color: color),
    const SizedBox(width: 3),
    Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  ],
);
