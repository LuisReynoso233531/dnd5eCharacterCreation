import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';

Widget classHeader(BuildContext context, dynamic cls, int level) {
  final hitDie = cls.hit_dice.toString();
  final spell = cls.spellcasting_ability ?? '';
  final primary = context.colors.primary;
  final darkerPrimary = Color.lerp(primary, Colors.black, 0.34)!;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primary, darkerPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cls.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _headerChip('Level $level'),
            _headerChip('$hitDie Hit Die'),
            if (spell.isNotEmpty) _headerChip('⚡ $spell'),
          ],
        ),
      ],
    ),
  );
}

Widget _headerChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}
