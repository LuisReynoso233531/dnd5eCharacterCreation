import 'package:flutter/material.dart';

import '../../../data/models/spell_model.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/school_colors.dart';

class SpellCard extends StatelessWidget {
  final SpellModel spell;
  final bool isSelected;
  final bool canAdd;
  final bool isAutomatic;
  final VoidCallback? onTap;
  final bool isCompendiumMode;

  const SpellCard({
    super.key,
    required this.spell,
    this.isSelected = false,
    this.canAdd = false,
    this.isAutomatic = false,
    this.onTap,
    this.isCompendiumMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = schoolColor(spell.school, isDark: context.isDarkMode);
    final selectedSurface = accent.withValues(alpha: context.isDarkMode ? 0.16 : 0.08);

    return GestureDetector(
      onTap: (!isCompendiumMode && !isAutomatic && (isSelected || canAdd))
          ? onTap
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedSurface : context.dndColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accent : context.dndColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? accent : accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isAutomatic
                    ? Icons.lock
                    : isSelected
                        ? Icons.check
                        : Icons.auto_fix_high,
                size: 16,
                color: isSelected
                    ? _onAccent(accent)
                    : accent,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    spell.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? accent : context.colors.onSurface,
                    ),
                  ),
                ),
                if (isAutomatic)
                  _badge('GRANTED', context.dndColors.info),
                if (spell.concentration)
                  _badge('C', context.dndColors.warning),
                const SizedBox(width: 2),
                if (spell.ritual) _badge('R', context.dndColors.success),
              ],
            ),
            subtitle: Row(
              children: [
                _schoolBadge(spell.school, accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    spell.castingTime,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.dndColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
            trailing: isCompendiumMode
                ? null
                : isAutomatic
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.dndColors.infoContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: context.dndColors.info.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'Granted',
                          style: TextStyle(
                            color: context.dndColors.onInfoContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 72,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(68, 38),
                            backgroundColor: isSelected
                                ? context.dndColors.danger
                                : accent,
                            foregroundColor: isSelected
                                ? context.dndColors.onDanger
                                : _onAccent(accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: (isSelected || canAdd) ? onTap : null,
                          child: Text(
                            isSelected ? 'Remove' : 'Add',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(context, Icons.bolt, 'Range: ${spell.range}'),
                    _detailRow(
                      context,
                      Icons.hourglass_empty,
                      'Duration: ${spell.duration}',
                    ),
                    _detailRow(
                      context,
                      Icons.gavel,
                      'Components: ${spell.components}',
                    ),
                    const Divider(),
                    Text(
                      spell.desc,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    if (spell.higherLevel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'At Higher Levels',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spell.higherLevel,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                          color: context.dndColors.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _onAccent(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black;

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        margin: const EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      );

  Widget _schoolBadge(String school, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          school.isEmpty ? '' : school[0].toUpperCase() + school.substring(1),
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _detailRow(BuildContext context, IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.dndColors.mutedText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
