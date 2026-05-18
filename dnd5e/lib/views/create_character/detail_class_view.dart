import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../widgets/create_character_view/detail_class_view/hint.dart';
import '../../widgets/create_character_view/detail_class_view/trait_block.dart';

const _kRed = Color(0xFFE50914);

class DetailClassView extends StatefulWidget {
  const DetailClassView({super.key});
  @override
  State<DetailClassView> createState() => _DetailClassViewState();
}

class _DetailClassViewState extends State<DetailClassView> {
  bool _raceExp = false;
  bool _bgExp = false;
  bool _classExp = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final dvm = context.watch<DetailClassViewModel>();
    final charClass = vm.selectedClass;

    if (charClass == null) {
      return Scaffold(
        appBar: _bar(),
        body: const Center(
          child: Text(
            'Select a class first.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final int conMod = vm.getModifier('Constitution');
    final int hitDieMax = dvm.parseHitDie(charClass.hit_dice);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (dvm.conModifier != conMod) dvm.setConModifier(conMod);
      dvm.syncLevels(vm.level, hitDieMax);
    });

    final archetypes =
        List<Map<String, dynamic>>.from(charClass.archetypes ?? []);
    final subtypesName = (charClass.subtypes_name?.isNotEmpty == true)
        ? charClass.subtypes_name!
        : 'Subclass';
    final unlockLevel = dvm.subclassUnlockLevelFor(charClass.slug);
    final canChoose = dvm.canChooseSubclass(charClass.slug, vm.level);

    return Scaffold(
      appBar: _bar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _classHeader(charClass, vm.level),
            const SizedBox(height: 24),
            const Divider(thickness: 1.2),

            // ── Hit Points ────────────────────────────────────────────────
            const Row(children: [
              Icon(Icons.favorite, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Hit Points',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            _buildHPSection(dvm, charClass.hit_dice, vm.level),

            const Divider(height: 40, thickness: 1.2),

            // ── Fighting Style (solo si aplica) ───────────────────────────
            _fightingStyleSection(dvm, charClass, vm.level),
            if (dvm.getAvailableFightingStyles(charClass, vm.level).isNotEmpty)
              const Divider(height: 40, thickness: 1.2),

            // ── Subclase ──────────────────────────────────────────────────
            _subclassSection(
              context,
              dvm: dvm,
              archetypes: archetypes,
              subtypesName: subtypesName,
              canChoose: canChoose,
              unlockLevel: unlockLevel,
            ),
            const Divider(height: 40, thickness: 1.2),

            // ── Racial + Background traits ─────────────────────────────────
            _raceSummary(vm),
            const SizedBox(height: 12),
            _backgroundSummary(vm),
            const SizedBox(height: 12),
            const Divider(height: 40, thickness: 1.2),

            // ── Class Features (Fighting Style integrado aquí) ─────────────
            _traitsSummary(vm, charClass, dvm),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _bar() =>
      AppBar(title: const Text('Class Details'), backgroundColor: _kRed);

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _classHeader(dynamic cls, int level) {
    final hitDie = cls.hit_dice.toString();
    final spell = cls.spellcasting_ability ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kRed.withOpacity(0.85), _kRed.withOpacity(0.45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cls.name,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _chip('Level $level'),
              _chip('$hitDie Hit Die'),
              if (spell.isNotEmpty) _chip('⚡ $spell'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      );

  // ── HP Section ────────────────────────────────────────────────────────────
  Widget _buildHPSection(
      DetailClassViewModel dvm, String? hitDiceRaw, int currentLevel) {
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
                  const Text('Maximum HP',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  Text('$totalHP',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1)),
                ],
              ),
              const Spacer(),
              Text('Die: 1d$hitDieMax',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 30)),
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
                  child: Text('Roll',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600))),
              SizedBox(
                width: 72,
                child: Text(
                  'Con (${conMod >= 0 ? '+' : ''}$conMod)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 52,
                child: Text('Total',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600)),
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
                            bottom:
                                BorderSide(color: Colors.grey.shade200)))
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          isLvl1 ? _kRed : Colors.grey.shade300,
                      child: Text('$lvl',
                          style: TextStyle(
                              color:
                                  isLvl1 ? Colors.white : Colors.black87,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLvl1
                          ? Row(children: [
                              const Icon(Icons.lock,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('$roll (max)',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500)),
                            ])
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
                                        color: Colors.redAccent),
                                    onPressed: roll > 1
                                        ? () => dvm.updateRoll(
                                            lvl, roll - 1, hitDieMax)
                                        : null,
                                  ),
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 28),
                                  alignment: Alignment.center,
                                  child: Text('$roll',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                        Icons.add_circle_outline,
                                        size: 20,
                                        color: Colors.green),
                                    onPressed: roll < hitDieMax
                                        ? () => dvm.updateRoll(
                                            lvl, roll + 1, hitDieMax)
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
                            fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text('$rowTotal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
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
                fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  // ── Fighting Style — AHORA DENTRO DE LA CLASE ─────────────────────────────
  Widget _fightingStyleSection(
      DetailClassViewModel dvm, dynamic charClass, int currentLevel) {
    final availableStyles =
        dvm.getAvailableFightingStyles(charClass, currentLevel);
    if (availableStyles.isEmpty) return const SizedBox.shrink();

    final selectedStyle = availableStyles.firstWhere(
      (s) => s['name'] == dvm.selectedFightingStyleName,
      orElse: () => {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.sports_martial_arts, color: Colors.indigo, size: 20),
          SizedBox(width: 8),
          Text('Fighting Style',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Fighting Style',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.indigo.shade50,
          ),
          value: availableStyles
                  .any((s) => s['name'] == dvm.selectedFightingStyleName)
              ? dvm.selectedFightingStyleName
              : null,
          items: availableStyles
              .map((s) => DropdownMenuItem<String>(
                    value: s['name'],
                    child: Text(s['name'] ?? ''),
                  ))
              .toList(),
          onChanged: (val) => dvm.setFightingStyleName(val),
        ),
        if (selectedStyle.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: Text(
              selectedStyle['desc'] ?? '',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ],
    );
  }

  // ── Subclase ──────────────────────────────────────────────────────────────
  Widget _subclassSection(
    BuildContext context, {
    required DetailClassViewModel dvm,
    required List<Map<String, dynamic>> archetypes,
    required String subtypesName,
    required bool canChoose,
    required int unlockLevel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.auto_awesome, color: _kRed, size: 20),
          const SizedBox(width: 8),
          Text(subtypesName,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),

        if (!canChoose)
          _infoBox(
            icon: Icons.lock_outline,
            color: Colors.amber,
            text: 'Your $subtypesName unlocks at level $unlockLevel.',
          ),

        if (canChoose) ...[
          if (dvm.selectedArchetype == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Choose your ${subtypesName.toLowerCase()}:',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: _kRed)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text('Selected: ${dvm.selectedArchetype!['name']}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
            ),
        ],

        ...archetypes.map((arch) => _archetypeCard(context,
            arch: arch, dvm: dvm, canChoose: canChoose)),
      ],
    );
  }

  Widget _archetypeCard(
    BuildContext context, {
    required Map<String, dynamic> arch,
    required DetailClassViewModel dvm,
    required bool canChoose,
  }) {
    final selSlug = dvm.selectedArchetype?['slug'] ?? '';
    final isSelected = selSlug.isNotEmpty && selSlug == arch['slug'];
    final name = arch['name'] ?? '';
    final desc = (arch['desc'] ?? '').toString();
    final dotIdx = desc.indexOf('.');
    final shortDesc = dotIdx > 0 && dotIdx < 150
        ? desc.substring(0, dotIdx + 1)
        : desc.length > 110
            ? '${desc.substring(0, 110)}…'
            : desc;

    return GestureDetector(
      onTap:
          canChoose ? () => dvm.selectArchetype(isSelected ? {} : arch) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kRed.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _kRed : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: isSelected ? _kRed : Colors.grey.shade100,
              child: Icon(isSelected ? Icons.check : Icons.shield_outlined,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey),
            ),
            title: Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _kRed : Colors.black87,
                    fontSize: 15)),
            subtitle: Text(shortDesc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 12, color: Colors.black54)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              Text(desc,
                  style: const TextStyle(fontSize: 13, height: 1.55)),
              if (canChoose) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.grey : _kRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () =>
                        dvm.selectArchetype(isSelected ? {} : arch),
                    icon: Icon(isSelected ? Icons.close : Icons.check,
                        size: 16),
                    label: Text(isSelected ? 'Deselect' : 'Select $name'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Racial summary ────────────────────────────────────────────────────────
  Widget _raceSummary(CreateCharacterViewModel vm) {
    final race = vm.selectedRace;
    if (race == null) return hint('Select a race to see racial traits.');
    return traitBlock(
      title: '${race['name']} — Racial Traits',
      icon: Icons.face,
      color: Colors.teal,
      raw: vm.getCleanedRaceTraits(),
      expanded: _raceExp,
      onToggle: () => setState(() => _raceExp = !_raceExp),
    );
  }

  // ── Background summary ────────────────────────────────────────────────────
  Widget _backgroundSummary(CreateCharacterViewModel vm) {
    final bg = vm.selectedBackground;
    if (bg == null) {
      return hint('Select a background to see its feature.');
    }
    return traitBlock(
      title: '${bg['name']} — ${bg['feature'] ?? 'Feature'}',
      icon: Icons.history_edu,
      color: Colors.blueGrey,
      raw: bg['feature_desc']?.toString() ?? '',
      expanded: _bgExp,
      onToggle: () => setState(() => _bgExp = !_bgExp),
    );
  }

  // ── Class Features — Fighting Style integrado ──────────────────────────────
  Widget _traitsSummary(
      CreateCharacterViewModel vm, dynamic cls, DetailClassViewModel dvm) {
    final buf = StringBuffer();

    // Info base
    final hpFirst = cls.hp_at_1st_level ?? '';
    final hpHigher = cls.hp_at_higher_levels ?? '';
    final saving = cls.prof_saving_throws ?? '';
    if (hpFirst.isNotEmpty) buf.writeln('HP at 1st Level:\n$hpFirst\n');
    if (hpHigher.isNotEmpty) buf.writeln('HP at Higher Levels:\n$hpHigher\n');
    if (saving.isNotEmpty) buf.writeln('Saving Throws:\n$saving\n');

    // Traits desbloqueados
    final unlockedFeatures = dvm.getUnlockedFeatures(cls, vm.level);
    final availableStyles = dvm.getAvailableFightingStyles(cls, vm.level);
    final hasFightingStyle = availableStyles.isNotEmpty;

    if (unlockedFeatures.isNotEmpty) {
      buf.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('UNLOCKED TRAITS (Level ${vm.level})\n');

      for (final feat in unlockedFeatures) {
        final titleLower = feat['title']!.toLowerCase();

        // Fighting Style: sustituir por la elección del usuario
        if (titleLower == 'fighting style' && hasFightingStyle) {
          if (dvm.selectedFightingStyleName != null) {
            final styleData = availableStyles.firstWhere(
              (s) => s['name'] == dvm.selectedFightingStyleName,
              orElse: () =>
                  {'name': dvm.selectedFightingStyleName!, 'desc': ''},
            );
            buf.writeln(
                'FIGHTING STYLE: ${styleData['name']!.toUpperCase()}');
            if ((styleData['desc'] ?? '').isNotEmpty) {
              buf.writeln('${styleData['desc']}\n');
            }
          } else {
            buf.writeln('FIGHTING STYLE');
            buf.writeln('(Select a fighting style in the section above)\n');
          }
          continue; // omitir el texto genérico
        }

        buf.writeln(feat['title']!.toUpperCase());
        buf.writeln('${feat['desc']}\n');
      }
    } else {
      buf.writeln('━━━━━━━━━━━━━━━━━━━━━━');
      buf.writeln('No specific traits unlocked at this level yet.');
    }

    return traitBlock(
      title: '${cls.name} — Class Features',
      icon: Icons.military_tech,
      color: _kRed,
      raw: buf.toString().trim(),
      expanded: _classExp,
      onToggle: () => setState(() => _classExp = !_classExp),
    );
  }

  // ── Info box (aviso de nivel bloqueado, etc.) ─────────────────────────────
  Widget _infoBox({
    required IconData icon,
    required MaterialColor color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade300),
      ),
      child: Row(children: [
        Icon(icon, color: color.shade800, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color.shade900,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }
}