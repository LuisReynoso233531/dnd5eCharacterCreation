// ─── Modelo de hechizo ────────────────────────────────────────────────────────
class SpellModel {
  final String slug;
  final String name;
  final int levelInt;
  final String school;
  final String castingTime;
  final String range;
  final String duration;
  final String components;
  final String desc;
  final String higherLevel;
  final String dndClass;
  final bool concentration;
  final bool ritual;

  const SpellModel({
    required this.slug,
    required this.name,
    required this.levelInt,
    required this.school,
    required this.castingTime,
    required this.range,
    required this.duration,
    required this.components,
    required this.desc,
    required this.higherLevel,
    required this.dndClass,
    required this.concentration,
    required this.ritual,
  });

  factory SpellModel.fromJson(Map<String, dynamic> j) => SpellModel(
    slug: j['slug'] ?? '',
    name: j['name'] ?? '',
    levelInt: j['level_int'] ?? j['spell_level'] ?? 0,
    school: j['school'] ?? '',
    castingTime: j['casting_time'] ?? '',
    range: j['range'] ?? '',
    duration: j['duration'] ?? '',
    components: j['components'] ?? '',
    desc: j['desc'] ?? '',
    higherLevel: j['higher_level'] ?? '',
    dndClass: j['dnd_class'] ?? '',
    concentration: j['requires_concentration'] ?? false,
    ritual: j['can_be_cast_as_ritual'] ?? false,
  );
}

// ─── Resultado de parsing de tabla de clase ───────────────────────────────────
class SpellcastingInfo {
  /// Hechizos que puede tener en total (null = dinámico según stats)
  final int? spellsKnown;

  /// Cantripos conocidos a este nivel
  final int cantripsKnown;

  /// Espacios de conjuro por nivel [nivel1..nivel9] (0 = no tiene)
  final List<int> slotsPerLevel;

  /// Solo para Warlock: slots totales y nivel de slot
  final int warlockSlots;
  final int warlockSlotLevel;

  const SpellcastingInfo({
    this.spellsKnown,
    required this.cantripsKnown,
    required this.slotsPerLevel,
    this.warlockSlots = 0,
    this.warlockSlotLevel = 0,
  });

  /// Nivel máximo de hechizo que puede conjurar
  int get maxSpellLevel {
    for (int i = 8; i >= 0; i--) {
      if (slotsPerLevel[i] > 0) return i + 1;
    }
    return warlockSlotLevel;
  }

  /// Si tiene algún espacio de conjuro
  bool get hasSpells => maxSpellLevel > 0 || warlockSlotLevel > 0;
}