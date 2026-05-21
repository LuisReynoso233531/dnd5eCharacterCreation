import 'package:dnd5e/data/repositories/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../widgets/create_character_view/detail_class_view/summary/traits_summary.dart';
import '../../widgets/create_character_view/detail_class_view/summary/background_summary.dart';
import '../../widgets/create_character_view/detail_class_view/summary/race_summary.dart';
import '../../widgets/create_character_view/detail_class_view/section/subclass_section.dart';
import '../../widgets/create_character_view/detail_class_view/section/fighting_style_section.dart';
import '../../widgets/create_character_view/detail_class_view/section/hp_section.dart';
import '../../widgets/create_character_view/detail_class_view/header.dart';
import '../../view_models/character/character_spell_view_model.dart';
import 'character_spell_selection_view.dart';
import '../../../utils/app_theme.dart';

class DetailClassView extends StatefulWidget {
  const DetailClassView({super.key});
  @override
  State<DetailClassView> createState() => _DetailClassViewState();
}

class _DetailClassViewState extends State<DetailClassView> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final dvm = context.watch<DetailClassViewModel>();
    final subclassVM = context.watch<CharacterSubclassViewModel>();
    final charClass = vm.selectedClass;
    final spellVM_isSpellcaster = (String slug) {
      const spellcastingClasses = [
        'bard',
        'cleric',
        'druid',
        'sorcerer',
        'warlock',
        'wizard',
      ];
      return spellcastingClasses.contains(slug);
    };

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

    final archetypes = List<Map<String, dynamic>>.from(
      charClass.archetypes ?? [],
    );
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
            classHeader(charClass, vm.level),
            const SizedBox(height: 24),
            const Divider(thickness: 1.2),

            // ── Hit Points ────────────────────────────────────────────────
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text(
                  'Hit Points',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildHPSection(dvm, charClass.hit_dice, vm.level),

            const Divider(height: 40, thickness: 1.2),

            // ── Fighting Style (solo si aplica) ───────────────────────────
            fightingStyleSection(dvm, charClass, vm.level),
            if (dvm.getAvailableFightingStyles(charClass, vm.level).isNotEmpty)
              const Divider(height: 40, thickness: 1.2),

            // ── Subclase ──────────────────────────────────────────────────
            subclassSection(
              context,
              dvm: dvm,
              subclassVM:
                  subclassVM, // <-- Pasamos el nuevo ViewModel de subclases
              archetypes: archetypes,
              subtypesName: subtypesName,
              canChoose: canChoose,
              unlockLevel: unlockLevel,
              // ── Construimos la lista de competencias actuales para mitigar duplicados ──
              existingSkills: [
                ...vm.skillVM.classFixedSkills,
                ...vm.skillVM.bgFixedSkills,
                ...vm.skillVM.selectedClassSkills,
              ],
            ),
            const Divider(height: 40, thickness: 1.2),

            // ── Racial + Background traits ─────────────────────────────────
            RaceTraitsSummary(),
            const SizedBox(height: 12),
            BackgroundTraitsSummary(),
            const SizedBox(height: 12),
            const Divider(height: 40, thickness: 1.2),

            // ── Class Features (Fighting Style integrado aquí) ─────────────
            ClassTraitsSummary(cls: charClass),
            if (spellVM_isSpellcaster(charClass.slug))
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A), // morado mágico
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (ctx) => CharacterSpellViewModel(
                              ctx.read<CharacterRepository>(),
                            ),
                            child: const CharacterSpellSelectionView(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_fix_high, size: 20),
                    label: const Text(
                      'Continue to Spell Selection',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _bar() => AppBar(
    title: const Text('Class Details'),
    backgroundColor: AppTheme.primaryRed,
  );
}
