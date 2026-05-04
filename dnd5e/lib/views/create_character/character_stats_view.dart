import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../views/create_character/character_details_view.dart';

class CharacterStatsView extends StatelessWidget {
  const CharacterStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final stats = [
      'Strength',
      'Dexterity',
      'Constitution',
      'Intelligence',
      'Wisdom',
      'Charisma',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ability Scores"),
        backgroundColor: const Color(0xFFE50914),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  // Cambiado a Column para meter el botón abajo
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Character Level",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton<int>(
                          value: vm.level,
                          items: List.generate(20, (i) => i + 1)
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l,
                                  child: Text("Lvl $l"),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => vm.updateLevel(val!),
                        ),
                      ],
                    ),
                    const Divider(), // Una línea separadora
                    // BOTÓN RANDOM
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showConfirmRoll(context, vm),
                        icon: const Icon(Icons.casino, color: Colors.red),
                        label: const Text(
                          "Roll Random Stats (4d6 drop lowest)",
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 20),

            // Tabla de Stats
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                final int base = vm.baseStats[stat]!;
                final int racialBonus = vm.racialBonuses[stat] ?? 0;
                final int total = vm.getTotalStat(
                  stat,
                ); // ya incluye feat + points
                final int mod = vm.getModifier(stat);

                // Calcula cuánto suman los levelUpChoices a este stat (feat + points)
                int improvementBonus = 0;
                vm.levelUpChoices.forEach((lvl, choice) {
                  if (lvl <= vm.level) {
                    if (choice['type'] == 'points') {
                      improvementBonus +=
                          (Map<String, int>.from(choice['data'])[stat] ?? 0);
                    }
                    if (choice['type'] == 'feat') {
                      final desc = (choice['data']['desc'] ?? '')
                          .toString()
                          .toLowerCase();
                      final s = stat.toLowerCase();
                      if (RegExp(
                        'increase your $s (score )?by 1|$s increases by 1',
                        caseSensitive: false,
                      ).hasMatch(desc)) {
                        improvementBonus += 1;
                      }
                    }
                  }
                });

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: improvementBonus > 0
                        ? Colors.amber[50]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: improvementBonus > 0
                          ? Colors.amber
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Nombre del stat
                      Expanded(
                        flex: 3,
                        child: Text(
                          stat,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Controles +/-
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                              ),
                              onPressed: base > 0
                                  ? () => vm.updateBaseStat(stat, base - 1)
                                  : null,
                            ),
                            Text(
                              "$base",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 20,
                              ),
                              onPressed: base < 20
                                  ? () => vm.updateBaseStat(stat, base + 1)
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // Total, Mod y bonuses
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Total: $total",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Mod: ${mod >= 0 ? '+' : ''}$mod",
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (racialBonus > 0)
                              Text(
                                "Race: +$racialBonus",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                ),
                              ),
                            // ← NUEVO: muestra el bonus de feat/points
                            if (improvementBonus > 0)
                              Text(
                                "Lvl Up: +$improvementBonus",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // SECCIÓN DE MEJORAS POR NIVEL (ASI / FEATS)
            if (vm.availableImprovementLevels.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Level Up Improvements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...vm.availableImprovementLevels.map(
                (lvl) => _buildImprovementTile(context, vm, lvl),
              ),
            ],

            // --- DENTRO DEL build DE CharacterStatsView ---
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // El botón se deshabilita si isLevelUpComplete es falso
                onPressed: vm.isLevelUpComplete
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CharacterSkillAndEquipmentView(),
                          ),
                        );
                      }
                    : null,
                child: Text(
                  vm.isLevelUpComplete
                      ? "Continue to Skills & Equipment"
                      : "Complete all Level Improvements to continue",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImprovementTile(
    BuildContext context,
    CreateCharacterViewModel vm,
    int level,
  ) {
    // Verificamos si ya hay una elección guardada para este nivel
    final choice = vm.levelUpChoices[level];
    String title = "Level $level Improvement";
    String subtitle = choice == null
        ? "Pending selection"
        : (choice['type'] == 'feat'
              ? "Feat: ${choice['data']['name']}"
              : "Points assigned");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: choice == null ? Colors.orange : Colors.green,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Select Improvement Type:"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Points (+2)"),
                      selected: choice?['type'] == 'points',
                      onSelected: (selected) {
                        // Aquí podrías abrir un diálogo para elegir qué stat subir

                        _showPointsDialog(context, vm, level);
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Feat"),
                      selected: choice?['type'] == 'feat',
                      onSelected: (selected) {
                        _showFeatsDialog(context, vm, level);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatsDialog(
    BuildContext context,
    CreateCharacterViewModel vm,
    int level,
  ) {
    // Disparamos la carga al abrir el diálogo
    vm.loadFeatsIfNeeded();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<CreateCharacterViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const AlertDialog(
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            // Filtramos dotes válidas según el JSON
            final validFeats = vm.allFeats
                .where((f) => vm.canTakeFeat(f))
                .toList();

            return AlertDialog(
              title: Text("Select Feat for Level $level"),
              content: SizedBox(
                width: double.maxFinite,
                child: validFeats.isEmpty
                    ? const Text("No cumples los requisitos para ninguna dote.")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: validFeats.length,
                        itemBuilder: (context, i) {
                          final feat = validFeats[i];
                          return Card(
                            child: ListTile(
                              title: Text(
                                feat['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                feat['prerequisite'] ?? "No requisites",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),

                              // Toque simple: Selecciona la dote
                              onTap: () {
                                Navigator.pop(
                                  context,
                                ); // cierra el diálogo de lista

                                final statChoice = _detectStatChoice(feat);

                                if (statChoice != null) {
                                  // El feat da "X or Y +1" — pedir elección
                                  _showFeatStatChoiceDialog(
                                    context,
                                    vm,
                                    level,
                                    feat,
                                    statChoice,
                                  );
                                } else {
                                  // Sin elección necesaria — confirmar directo
                                  vm.setLevelChoice(level, 'feat', feat);
                                }
                              },

                              // TOQUE LARGO: Muestra la información sin seleccionar
                              onLongPress: () {
                                _showFeatDetails(context, feat);
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPointsDialog(
    BuildContext context,
    CreateCharacterViewModel vm,
    int level,
  ) {
    String? firstStat;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("ASI: Choose Points"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Option 1: +2 to one stat"),
              Wrap(
                children: vm.baseStats.keys
                    .map(
                      (s) => TextButton(
                        onPressed: () {
                          vm.setLevelChoice(level, 'points', {s: 2});
                          Navigator.pop(context);
                        },
                        child: Text("+2 $s"),
                      ),
                    )
                    .toList(),
              ),
              const Divider(),
              const Text("Option 2: +1 to two stats"),

              // Lógica simple: Selecciona el primero, luego el segundo
              Text(
                firstStat == null
                    ? "Select first stat"
                    : "First: $firstStat. Select second:",
              ),
              Wrap(
                children: vm.baseStats.keys
                    .map(
                      (s) => TextButton(
                        onPressed: firstStat == s
                            ? null
                            : () {
                                if (firstStat == null) {
                                  setState(() => firstStat = s);
                                } else {
                                  vm.setLevelChoice(level, 'points', {
                                    firstStat!: 1,
                                    s: 1,
                                  });
                                  Navigator.pop(context);
                                }
                              },
                        child: Text("+1 $s"),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmRoll(BuildContext context, CreateCharacterViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Roll Random Stats?"),
        content: const Text(
          "This will replace your current base statistics. Are you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              vm.rollRandomStats();
              Navigator.pop(context);
            },
            child: const Text(
              "Roll Dice!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatDetails(BuildContext context, Map<String, dynamic> feat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    feat['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE50914),
                    ),
                  ),
                  if (feat['prerequisite'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Requisito: ${feat['prerequisite']}",
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const Divider(height: 30),
                  Text(
                    feat['desc'] ?? "Sin descripción disponible.",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  // Si el JSON tiene efectos específicos:
                  if (feat['effects_desc'] != null) ...[
                    const Text(
                      "Effects:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...(feat['effects_desc'] as List).map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• "),
                            Expanded(child: Text(e.toString())),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
/// Detecta si un feat requiere elegir entre dos stats.
/// Retorna la lista de opciones o null si no aplica.
List<String>? _detectStatChoice(Map<String, dynamic> feat) {
  final effects = (feat['effects_desc'] as List? ?? []);
  final statNames = ['Strength', 'Dexterity', 'Constitution',
                     'Intelligence', 'Wisdom', 'Charisma'];

  for (var e in effects) {
    final text = e.toString();
    // Busca patrón "Your X or Y score increases by 1"
    if (text.toLowerCase().contains(' or ') &&
        (text.toLowerCase().contains('score increases') ||
         text.toLowerCase().contains('score by 1') ||
         text.toLowerCase().contains('attribute by 1'))) {
      // Extrae qué stats menciona
      final found = statNames.where((s) =>
          text.toLowerCase().contains(s.toLowerCase())).toList();
      if (found.length >= 2) return found;
    }
  }
  return null;
}

void _showFeatStatChoiceDialog(
  BuildContext context,
  CreateCharacterViewModel vm,
  int level,
  Map<String, dynamic> feat,
  List<String> options,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("${feat['name']}: Choose Stat Bonus"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "This feat increases one of the following stats by 1.\nChoose which one to apply:",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...options.map((stat) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[800],
                  side: BorderSide(color: Colors.red[300]!),
                ),
                onPressed: () {
                  vm.setLevelChoice(
                    level,
                    'feat',
                    feat,
                    featChoice: ResolvedFeatChoice(chosenStat: stat),
                  );
                  Navigator.pop(context);
                },
                child: Text("+1 $stat"),
              ),
            ),
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
      ],
    ),
  );
}
