import 'package:flutter/material.dart';
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

    // Hechizos de este nivel disponibles para esta clase
    final levelSpells = spellVM
        .filteredSpells(classSlug, spellLevel)
        .where((s) => s.levelInt == spellLevel)
        .toList();

    // Contadores según el tipo
    final int selectedCount = isCantrip
        ? spellVM.totalCantripsSelected
        : spellVM.totalNonCantripSelected;
    final int maxAllowed = isCantrip ? cantripsMax : globalSpellsMax;
    final int remaining = maxAllowed - selectedCount;

    if (levelSpells.isEmpty) {
      return const Center(
        child: Text(
          'No spells found for this level.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // ── Indicador de progreso ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey.shade100,
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
                        color: Colors.grey.shade500,
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
                  color: remaining > 0
                      ? Colors.green.shade100
                      : const Color(0xFFE50914).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: remaining > 0
                        ? Colors.green.shade400
                        : const Color(0xFFE50914).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '$selectedCount / $maxAllowed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: remaining > 0
                        ? Colors.green.shade700
                        : const Color(0xFFE50914),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Lista de hechizos ──────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: levelSpells.length,
            itemBuilder: (context, i) {
              final spell = levelSpells[i];
              final isSel = spellVM.isSelected(spell.slug, spellLevel);
              // canAdd: solo si hay espacio en el pool correspondiente
              final canAdd = !isSel && remaining > 0;

              return SpellCard(
                spell: spell,
                isSelected: isSel,
                canAdd: canAdd,
                onTap: () {
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
