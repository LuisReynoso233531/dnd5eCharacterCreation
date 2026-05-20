import 'package:flutter/material.dart';
import '../../../data/models/spell_model.dart';
import '../../../utils/school_colors.dart';

class SpellCard extends StatelessWidget {
  final SpellModel spell;
  final bool isSelected;
  final bool canAdd;
  final VoidCallback onTap;

  const SpellCard({
    super.key,
    required this.spell,
    required this.isSelected,
    required this.canAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = schoolColor(spell.school);

    return GestureDetector(
      onTap: (isSelected || canAdd) ? onTap : null,
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
                // Badges
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
            // Botón select/deselect visible cuando está colapsado
            trailing: SizedBox(
              width: 72,
              child: (isSelected || canAdd)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.grey.shade400
                            : color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(64, 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(
                        isSelected ? 'Remove' : 'Add',
                        style: const TextStyle(fontSize: 11),
                      ),
                    )
                  : null,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              // Detalles del hechizo
              _detailRow(Icons.timer, spell.castingTime),
              _detailRow(Icons.place, spell.range),
              _detailRow(Icons.access_time, spell.duration),
              _detailRow(Icons.extension, spell.components),
              const SizedBox(height: 8),
              Text(
                spell.desc,
                style: const TextStyle(fontSize: 12, height: 1.5),
              ),
              if (spell.higherLevel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_upward, size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'At Higher Levels: ${spell.higherLevel}',
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Botón prominente al fondo de la tarjeta expandida
              if (isSelected || canAdd)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.grey : color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTap,
                    icon: Icon(
                      isSelected ? Icons.remove_circle : Icons.add_circle,
                      size: 16,
                    ),
                    label: Text(
                      isSelected ? 'Remove ${spell.name}' : 'Add ${spell.name}',
                      style: const TextStyle(fontSize: 13),
                    ),
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
      school[0].toUpperCase() + school.substring(1),
      style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
    ),
  );

  Widget _detailRow(IconData icon, String text) => text.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              Icon(icon, size: 13, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        );
}
