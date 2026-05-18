import 'package:flutter/material.dart';
import '../../../../view_models/character/character_detail_class_view_model.dart';
import '../../../../utils/app_theme.dart';

Widget buildHPSection(
  DetailClassViewModel dvm,
  String? hitDiceRaw,
  int currentLevel,
) {
  final int hitDieMax = dvm.parseHitDie(hitDiceRaw);
  final int totalHP = dvm.calculateTotalHP();
  final int conMod = dvm.conModifier;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Tarjeta de total
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade700, Colors.red.shade400],
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
              style: const TextStyle(color: Colors.white70, fontSize: 30),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),

      // Encabezado de columnas
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 48),
            const Expanded(
              child: Text(
                'Roll',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 72,
              child: Text(
                'Con (${conMod >= 0 ? '+' : ''}$conMod)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey,
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
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      // Filas por nivel
      Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: List.generate(currentLevel, (index) {
            final int lvl = index + 1;
            final int roll = dvm.hpRolls[lvl] ?? hitDieMax;
            final bool isLvl1 = lvl == 1;
            final int rowTotal = roll + conMod;

            return Container(
              decoration: index < currentLevel - 1
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    )
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isLvl1
                        ? AppTheme.primaryRed
                        : Colors.grey.shade300,
                    child: Text(
                      '$lvl',
                      style: TextStyle(
                        color: isLvl1 ? Colors.white : Colors.black87,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLvl1
                        ? Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$roll (max)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: roll > 1
                                      ? () => dvm.updateRoll(
                                          lvl,
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
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  onPressed: roll < hitDieMax
                                      ? () => dvm.updateRoll(
                                          lvl,
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
                            ? Colors.blueGrey
                            : Colors.deepOrange,
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
                        color: Colors.red.shade700,
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
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    ],
  );
}
