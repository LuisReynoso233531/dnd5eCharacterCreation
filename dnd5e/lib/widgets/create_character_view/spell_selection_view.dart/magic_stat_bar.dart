import 'package:flutter/material.dart';

import '../../../data/models/spell_model.dart';
import '../../../utils/app_theme.dart';
import '../../../view_models/character/character_spell_view_model.dart';
import 'slots_summary.dart';

Widget magicStatsBar(
  BuildContext context,
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
  final background = context.isDarkMode
      ? context.dndColors.surfaceStrong
      : const Color(0xFF25272D);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    color: background,
    child: Column(
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            _statChip(Icons.auto_fix_high, ability, const Color(0xFFD7B3FF)),
            _statChip(
              Icons.add_circle_outline,
              '${attackBonus >= 0 ? '+' : ''}$attackBonus Atk',
              const Color(0xFFFFC38A),
            ),
            _statChip(Icons.shield, 'DC $saveDC', const Color(0xFFA9D3FF)),
            _statChip(
              Icons.menu_book,
              '${spellVM.totalCantripsTowardLimit}/${info.cantripsKnown} cantrips  '
              '${spellVM.totalNonCantripsTowardLimit}/$spellsKnown spells'
              '${spellVM.totalAutomaticSpells > 0 ? ' +${spellVM.totalAutomaticSpells} granted' : ''}',
              const Color(0xFFA8E9B9),
            ),
          ],
        ),
        const SizedBox(height: 6),
        slotsSummary(classSlug, info),
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
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFFD7B3FF),
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(spellVM.loadProgress * 100).toInt()}% spells',
                style: const TextStyle(color: Colors.white60, fontSize: 10),
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
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
