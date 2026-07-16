import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';

Widget buildHPSection(
  BuildContext context,
  DetailClassViewModel dvm,
  String? hitDiceRaw,
  int currentLevel,
) {
  final hitDieMax = dvm.parseHitDie(hitDiceRaw);
  final totalHP = dvm.calculateTotalHP();
  final conMod = dvm.conModifier;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.isDarkMode
                ? const [Color(0xFF8F1018), Color(0xFF5C1117)]
                : [Colors.red.shade700, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Maximum HP',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$totalHP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Die: 1d$hitDieMax',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 48),
            const Expanded(
              child: Text(
                'Roll',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 72,
              child: Text(
                'Con (${conMod >= 0 ? '+' : ''}$conMod)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: context.dndColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                'Total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: context.dndColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: context.dndColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.dndColors.border),
        ),
        child: Column(
          children: List.generate(currentLevel, (index) {
            final level = index + 1;
            final roll = dvm.hpRolls[level] ?? hitDieMax;
            final isLevelOne = level == 1;
            final rowTotal = roll + conMod;

            return Container(
              decoration: index < currentLevel - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: context.dndColors.border),
                      ),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isLevelOne
                        ? context.colors.primary
                        : context.dndColors.surfaceStrong,
                    child: Text(
                      '$level',
                      style: TextStyle(
                        color: isLevelOne
                            ? context.colors.onPrimary
                            : context.colors.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLevelOne
                        ? Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: context.dndColors.subtleText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$roll (max)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.dndColors.mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                    color: context.dndColors.danger,
                                  ),
                                  onPressed: roll > 1
                                      ? () => dvm.updateRoll(
                                            level,
                                            roll - 1,
                                            hitDieMax,
                                          )
                                      : null,
                                ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 28),
                                alignment: Alignment.center,
                                child: Text(
                                  '$roll',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color: context.dndColors.success,
                                  ),
                                  onPressed: roll < hitDieMax
                                      ? () => dvm.updateRoll(
                                            level,
                                            roll + 1,
                                            hitDieMax,
                                          )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '${conMod >= 0 ? '+' : ''}$conMod',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: conMod >= 0
                            ? context.dndColors.info
                            : context.dndColors.warning,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '$rowTotal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.dndColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Level 1 always uses the maximum die value. '
          "Adjust each level's roll to match your actual dice results.",
          style: TextStyle(
            fontSize: 11,
            color: context.dndColors.mutedText,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ],
  );
}
