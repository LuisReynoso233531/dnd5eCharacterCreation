import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';

Widget infoBox({
  required IconData icon,
  required MaterialColor color,
  required String text,
}) {
  return Builder(
    builder: (context) {
      final accent = context.isDarkMode ? color.shade300 : color.shade800;
      final background = Color.lerp(
        context.dndColors.surfaceRaised,
        color,
        context.isDarkMode ? 0.18 : 0.09,
      )!;

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.58)),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
