class SubclassSpellGrant {
  final int characterLevel;
  final String spellName;

  /// true cuando el hechizo forma parte del límite normal de la tabla.
  /// Ejemplo: Mage Hand del Eldritch Trickster cuenta entre sus cantrips.
  final bool countsAgainstLimit;

  const SubclassSpellGrant({
    required this.characterLevel,
    required this.spellName,
    this.countsAgainstLimit = false,
  });
}

class SubclassSpellTable {
  final String id;
  final String title;
  final List<SubclassSpellGrant> grants;

  const SubclassSpellTable({
    required this.id,
    required this.title,
    required this.grants,
  });

  List<SubclassSpellGrant> grantsAvailableAt(int characterLevel) {
    return grants
        .where((grant) => grant.characterLevel <= characterLevel)
        .toList(growable: false);
  }
}
