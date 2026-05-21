import 'package:flutter/material.dart';
import '../../../data/models/spell_model.dart';

Widget slotsSummary(String slug, SpellcastingInfo info) {
  if (slug == 'warlock') {
    return Text(
      '${info.warlockSlots} slot(s) · Level ${info.warlockSlotLevel}',
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    );
  }

  final slotsText = info.slotsPerLevel
      .asMap()
      .entries
      .where((e) => e.value > 0)
      .map((e) => 'L${e.key + 1}:${e.value}')
      .join('  ');

  return Text(
    'Spell Slots: $slotsText',
    style: const TextStyle(color: Colors.white, fontSize: 12),
  );
}
