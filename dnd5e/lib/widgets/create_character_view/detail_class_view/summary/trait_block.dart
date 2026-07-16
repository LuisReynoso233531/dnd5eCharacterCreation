import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import 'hint.dart';

Widget traitBlock({
  required String title,
  required IconData icon,
  required Color color,
  required String raw,
  required bool expanded,
  required VoidCallback onToggle,
}) {
  final clean = raw
      .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();

  if (clean.isEmpty) return hint('No description available.');

  return Builder(
    builder: (context) {
      final accent = context.isDarkMode
          ? Color.lerp(color, Colors.white, 0.32)!
          : color;

      return Container(
        decoration: BoxDecoration(
          color: context.dndColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.42)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: accent,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  clean,
                  style: const TextStyle(fontSize: 13, height: 1.55),
                ),
              ),
          ],
        ),
      );
    },
  );
}
