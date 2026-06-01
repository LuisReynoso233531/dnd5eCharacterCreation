import 'package:flutter/material.dart';
import '../../../data/models/spell_model.dart';
import '../../../utils/school_colors.dart';

class SpellCard extends StatelessWidget {
  final SpellModel spell;
  final bool isSelected;
  final bool canAdd;
  final VoidCallback? onTap;
  final bool isCompendiumMode;

  const SpellCard({
    super.key,
    required this.spell,
    this.isSelected = false, 
    this.canAdd = false, 
    this.onTap, 
    this.isCompendiumMode =
        false,
  });

  @override
  Widget build(BuildContext context) {
    final color = schoolColor(spell.school);

    return GestureDetector(
      onTap: (!isCompendiumMode && (isSelected || canAdd)) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.auto_fix_high,
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    spell.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                ),
                if (spell.concentration) _badge('C', Colors.orange),
                const SizedBox(width: 2),
                if (spell.ritual) _badge('R', Colors.teal),
              ],
            ),
            subtitle: Row(
              children: [
                _schoolBadge(spell.school, color),
                const SizedBox(width: 6),
                Text(
                  spell.castingTime,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
            trailing: isCompendiumMode
                ? null
                : SizedBox(
                    width: 72,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isSelected
                            ? Colors.red.shade700
                            : color,
                        foregroundColor: Colors.white,
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
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(Icons.bolt, 'Range: ${spell.range}'),
                    _detailRow(
                      Icons.hourglass_empty,
                      'Duration: ${spell.duration}',
                    ),
                    _detailRow(Icons.gavel, 'Components: ${spell.components}'),
                    const Divider(),
                    Text(
                      spell.desc,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    if (spell.higherLevel.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "At Higher Levels",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        spell.higherLevel,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
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

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    margin: const EdgeInsets.only(left: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
    ),
  );

  Widget _schoolBadge(String school, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      school.isEmpty ? '' : school[0].toUpperCase() + school.substring(1),
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
    ),
  );

  Widget _detailRow(IconData icon, String text) => text.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
}
