import 'package:dnd5e/data/repositories/character_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart'
    as inv_vm;
import '../../views/create_character/character_inventory_view.dart' as inv_view;
import '../../view_models/character/character_spell_view_model.dart';
import '../../views/create_character/character_spell_selection_view.dart';
import '../../widgets/create_character_view/detail_class_view/summary/traits_summary.dart';
import '../../widgets/create_character_view/detail_class_view/summary/background_summary.dart';
import '../../widgets/create_character_view/detail_class_view/summary/race_summary.dart';
import '../../widgets/create_character_view/detail_class_view/section/subclass_section.dart';
import '../../widgets/create_character_view/detail_class_view/section/fighting_style_section.dart';
import '../../widgets/create_character_view/detail_class_view/section/hp_section.dart';
import '../../widgets/create_character_view/detail_class_view/section/expertise_section.dart';
import '../../widgets/create_character_view/detail_class_view/header.dart';
import '../../utils/app_theme.dart';
import '../../utils/spellcasting_source.dart';
import '../../view_models/character/character_skill_view_model.dart';

class DetailClassView extends StatefulWidget {
  const DetailClassView({super.key});
  @override
  State<DetailClassView> createState() => _DetailClassViewState();
}

class _DetailClassViewState extends State<DetailClassView> {

  List<String> _expertiseOptions(
    CreateCharacterViewModel vm,
    CharacterSubclassViewModel subclassVM,
  ) {
    final canonicalSkills = CharacterSkillViewModel.allDndSkills;
    final options = <String>{
      ...vm.skillVM.classFixedSkills,
      ...vm.skillVM.bgFixedSkills,
      ...vm.skillVM.selectedClassSkills.where((skill) => skill.isNotEmpty),
      ...vm.racialSkillProficiencies,
      ...subclassVM.automaticSkills,
      ...subclassVM.selectedBonusSkills,
    };

    // Incluye las competencias de habilidad obtenidas por feats.
    for (final proficiency in vm.featProficiencies) {
      final lower = proficiency.toLowerCase();
      for (final skill in canonicalSkills) {
        if (lower.contains(skill.toLowerCase())) {
          options.add(skill);
        }
      }
    }

    // Rogue puede elegir Thieves' Tools como una de sus Pericias.
    final classSlug = vm.selectedClass?.slug.toLowerCase() ?? '';
    final toolText = vm.selectedClass?.prof_tools?.toLowerCase() ?? '';
    if (classSlug == 'rogue' && toolText.contains('thieves')) {
      options.add(CharacterSkillViewModel.thievesToolsExpertise);
    }

    final result = options.where((item) => item.trim().isNotEmpty).toList();
    result.sort();
    return result;
  }

  bool _validateExpertise(BuildContext context) {
    final vm = context.read<CreateCharacterViewModel>();
    final subclassVM = context.read<CharacterSubclassViewModel>();
    final charClass = vm.selectedClass;

    if (charClass == null) return true;

    final requiredChoices = vm.skillVM.expertiseChoiceCount(
      classSlug: charClass.slug,
      characterLevel: vm.level,
    );

    if (requiredChoices == 0) return true;

    final allowed = _expertiseOptions(vm, subclassVM)
        .map((item) => item.toLowerCase().trim())
        .toSet();

    final validSelected = vm.skillVM.selectedExpertise
        .map((item) => item.toLowerCase().trim())
        .where((item) => item.isNotEmpty && allowed.contains(item))
        .toSet();

    if (validSelected.length >= requiredChoices) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Choose all $requiredChoices Expertise proficiencies before continuing.',
        ),
      ),
    );
    return false;
  }
  // ── Navega a Hechizos ─────────────────────────────────────────────────────
  void _goToSpells(BuildContext context) {
    if (!_validateExpertise(context)) return;

    final dvm = context.read<DetailClassViewModel>();
    final subVM = context.read<CharacterSubclassViewModel>();

    if (subVM.requiresSpellTableChoice &&
        subVM.selectedSpellTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose the subclass spell list before continuing.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dvm),
            ChangeNotifierProvider.value(value: subVM),
            ChangeNotifierProvider(
              create: (ctx) =>
                  CharacterSpellViewModel(ctx.read<CharacterRepository>()),
            ),
          ],
          child: const CharacterSpellSelectionView(),
        ),
      ),
    );
  }

  // ── Navega a Inventario ───────────────────────────────────────────────────
  void _goToInventory(CreateCharacterViewModel vm) {
    if (!_validateExpertise(context)) return;

    // Capturamos dvm y subclassVM ANTES de navegar — aún están en scope
    final dvm   = context.read<DetailClassViewModel>();
    final subVM = context.read<CharacterSubclassViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: dvm),
            ChangeNotifierProvider.value(value: subVM),
            ChangeNotifierProvider(
              create: (ctx) {
                final invVM = inv_vm.CharacterInventoryViewModel(
                  ctx.read<CharacterRepository>(),
                );
                invVM.updateFromBackground(vm.selectedBackground);
                return invVM;
              },
            ),
          ],
          child: const inv_view.CharacterInventoryView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final dvm = context.watch<DetailClassViewModel>();
    final subclassVM = context.watch<CharacterSubclassViewModel>();
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

    final archetypes = List<Map<String, dynamic>>.from(
      charClass.archetypes ?? [],
    );
    final subtypesName = (charClass.subtypes_name?.isNotEmpty == true)
        ? charClass.subtypes_name!
        : 'Subclass';
    final unlockLevel = dvm.subclassUnlockLevelFor(charClass.slug);
    final canChoose = dvm.canChooseSubclass(charClass.slug, vm.level);
    final spellSource = SpellcastingSourceResolver.resolve(
      characterClass: charClass,
      characterLevel: vm.level,
      archetype: dvm.selectedArchetype,
    );
    final hasSpellSelection =
        spellSource?.hasSpellSelectionAtLevel(vm.level) ?? false;
    final expertiseCount = vm.skillVM.expertiseChoiceCount(
      classSlug: charClass.slug,
      characterLevel: vm.level,
    );
    final expertiseOptions = _expertiseOptions(vm, subclassVM);

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
              subclassVM: subclassVM,
              archetypes: archetypes,
              subtypesName: subtypesName,
              canChoose: canChoose,
              unlockLevel: unlockLevel,
              characterLevel: vm.level,
              existingSkills: [
                ...vm.skillVM.classFixedSkills,
                ...vm.skillVM.bgFixedSkills,
                ...vm.skillVM.selectedClassSkills,
              ],
            ),

            if (expertiseCount > 0) ...[
              const Divider(height: 40, thickness: 1.2),
              ExpertiseSection(
                skillVM: vm.skillVM,
                classSlug: charClass.slug,
                characterLevel: vm.level,
                availableProficiencies: expertiseOptions,
                proficiencyBonus:
                    CreateCharacterViewModel.proficiencyBonus(vm.level),
              ),
            ],

            const Divider(height: 40, thickness: 1.2),

            // ── Racial + Background traits ─────────────────────────────────
            RaceTraitsSummary(),
            const SizedBox(height: 12),
            BackgroundTraitsSummary(),
            const SizedBox(height: 12),
            const Divider(height: 40, thickness: 1.2),

            // ── Class Features ────────────────────────────────────────────
            ClassTraitsSummary(cls: charClass),
            const SizedBox(height: 24),

            // ── Botón de navegación condicional ───────────────────────────
            // Lanzadores → Hechizos. Resto → Inventario directamente.
            if (hasSpellSelection)
              _navButton(
                label: 'Continue to Spell Selection',
                icon: Icons.auto_fix_high,
                color: const Color(0xFF6A1B9A),
                onPressed: () => _goToSpells(context),
              )
            else
              _navButton(
                label: 'Continue to Inventory',
                icon: Icons.backpack,
                color: const Color(0xFF2E7D32),
                onPressed: () => _goToInventory(vm),
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

  // ── Botón de navegación reutilizable ──────────────────────────────────────
  Widget _navButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}