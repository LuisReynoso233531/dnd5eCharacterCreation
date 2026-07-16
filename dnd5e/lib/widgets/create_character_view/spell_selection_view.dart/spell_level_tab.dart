import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';
import '../../../view_models/character/character_spell_view_model.dart';
import 'spell_card.dart';

class SpellLevelTab extends StatelessWidget {
  final int spellLevel;
  final String classSlug;
  final int globalSpellsMax;
  final int cantripsMax;
  final CharacterSpellViewModel spellVM;

  const SpellLevelTab({
    super.key,
    required this.spellLevel,
    required this.classSlug,
    required this.globalSpellsMax,
    required this.cantripsMax,
    required this.spellVM,
  });

  @override
  Widget build(BuildContext context) {
    final isCantrip = spellLevel == 0;
    final levelSpells = spellVM
        .filteredSpells(classSlug, spellLevel)
        .where((spell) => spell.levelInt == spellLevel)
        .toList();

    final selectedCount = isCantrip
        ? spellVM.totalCantripsTowardLimit
        : spellVM.totalNonCantripsTowardLimit;
    final maxAllowed = isCantrip ? cantripsMax : globalSpellsMax;
    final remaining = maxAllowed - selectedCount;

    if (levelSpells.isEmpty) {
      return Center(
        child: Text(
          'No spells found for this level.',
          style: TextStyle(color: context.dndColors.mutedText),
        ),
      );
    }

    final counterColor = remaining > 0
        ? context.dndColors.success
        : context.dndColors.danger;
    final counterContainer = remaining > 0
        ? context.dndColors.successContainer
        : context.dndColors.dangerContainer;
    final counterText = remaining > 0
        ? context.dndColors.onSuccessContainer
        : context.dndColors.onDangerContainer;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          color: context.dndColors.surfaceMuted,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCantrip ? 'Cantrips' : 'Level $spellLevel Spells',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (!isCantrip)
                    Text(
                      'Shared pool across all spell levels',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.dndColors.mutedText,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: counterContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: counterColor.withValues(alpha: 0.55),
                  ),
                ),
                child: Text(
                  '$selectedCount / $maxAllowed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: counterText,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: levelSpells.length,
            itemBuilder: (context, i) {
              final spell = levelSpells[i];
              final isAutomatic = spellVM.isAutomaticSpell(spell.slug);
              final isSelected = spellVM.isSelected(spell.slug, spellLevel);
              final canAdd = !isAutomatic && !isSelected && remaining > 0;

              return SpellCard(
                spell: spell,
                isSelected: isSelected,
                isAutomatic: isAutomatic,
                canAdd: canAdd,
                onTap: isAutomatic
                    ? null
                    : () {
                        if (isCantrip) {
                          spellVM.toggleCantrip(spell.slug, cantripsMax);
                        } else {
                          spellVM.toggleSpell(
                            spell.slug,
                            spellLevel,
                            globalSpellsMax,
                          );
                        }
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}
