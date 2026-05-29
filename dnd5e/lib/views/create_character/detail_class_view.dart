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
import '../../widgets/create_character_view/detail_class_view/header.dart';
import '../../../utils/app_theme.dart';

class DetailClassView extends StatefulWidget {
  const DetailClassView({super.key});
  @override
  State<DetailClassView> createState() => _DetailClassViewState();
}

class _DetailClassViewState extends State<DetailClassView> {
  // Clases que tienen hechizos
  static const _spellcasterSlugs = [
    'bard',
    'cleric',
    'druid',
    'paladin',
    'ranger',
    'sorcerer',
    'warlock',
    'wizard',
  ];

  bool _isSpellcaster(String slug) => _spellcasterSlugs.contains(slug);

  // ── Navega a Hechizos ─────────────────────────────────────────────────────
  void _goToSpells(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) =>
              CharacterSpellViewModel(ctx.read<CharacterRepository>()),
          child: const CharacterSpellSelectionView(),
        ),
      ),
    );
  }

  // ── Navega a Inventario ───────────────────────────────────────────────────
  void _goToInventory(CreateCharacterViewModel vm) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (ctx) {
            final invVM = inv_vm.CharacterInventoryViewModel(
              ctx.read<CharacterRepository>(),
            );
            invVM.updateFromBackground(vm.selectedBackground);
            return invVM;
          },
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
    final isSpellcaster = _isSpellcaster(charClass.slug);

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

            // ── Class Features ────────────────────────────────────────────
            ClassTraitsSummary(cls: charClass),
            const SizedBox(height: 24),

            // ── Botón de navegación condicional ───────────────────────────
            // Lanzadores → Hechizos. Resto → Inventario directamente.
            if (isSpellcaster)
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
