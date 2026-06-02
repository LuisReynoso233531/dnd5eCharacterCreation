class MonsterModel {
  final String slug;
  final String name;
  final String size;
  final String type;
  final String alignment;
  final int armorClass;
  final int hitPoints;
  final String hitDice;
  final String challengeRating;
  final String senses;
  final String languages;
  
  // ── Puntuaciones de características ──
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  // ── Resistencias e Inmunidades ──
  final String damageVulnerabilities;
  final String damageResistances;
  final String damageImmunities;
  final String conditionImmunities;

  // ── Acciones y Rasgos ──
  final List<dynamic> specialAbilities;
  final List<dynamic> actions;
  final List<dynamic> bonusActions;
  final List<dynamic> reactions;
  final String legendaryDesc;
  final List<dynamic> legendaryActions;

  MonsterModel({
    required this.slug,
    required this.name,
    required this.size,
    required this.type,
    required this.alignment,
    required this.armorClass,
    required this.hitPoints,
    required this.hitDice,
    required this.challengeRating,
    required this.senses,
    required this.languages,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.damageVulnerabilities,
    required this.damageResistances,
    required this.damageImmunities,
    required this.conditionImmunities,
    required this.specialAbilities,
    required this.actions,
    required this.bonusActions,
    required this.reactions,
    required this.legendaryDesc,
    required this.legendaryActions,
  });

  factory MonsterModel.fromJson(Map<String, dynamic> json) {
    return MonsterModel(
      slug: json['slug'] ?? '',
      name: json['name'] ?? 'Unknown',
      size: json['size'] ?? '',
      type: json['type'] ?? 'Unknown',
      alignment: json['alignment'] ?? '',
      armorClass: json['armor_class'] ?? 10,
      hitPoints: json['hit_points'] ?? 0,
      hitDice: json['hit_dice'] ?? '',
      challengeRating: json['challenge_rating']?.toString() ?? '0',
      senses: json['senses'] ?? '',
      languages: json['languages'] ?? '',
      
      strength: json['strength'] ?? 10,
      dexterity: json['dexterity'] ?? 10,
      constitution: json['constitution'] ?? 10,
      intelligence: json['intelligence'] ?? 10,
      wisdom: json['wisdom'] ?? 10,
      charisma: json['charisma'] ?? 10,

      damageVulnerabilities: json['damage_vulnerabilities'] ?? '',
      damageResistances: json['damage_resistances'] ?? '',
      damageImmunities: json['damage_immunities'] ?? '',
      conditionImmunities: json['condition_immunities'] ?? '',

      specialAbilities: json['special_abilities'] ?? [],
      actions: json['actions'] ?? [],
      // Cuidado aquí: la API a veces manda null para estas listas, usamos ?? []
      bonusActions: json['bonus_actions'] ?? [],
      reactions: json['reactions'] ?? [],
      legendaryDesc: json['legendary_desc'] ?? '',
      legendaryActions: json['legendary_actions'] ?? [],
    );
  }
}