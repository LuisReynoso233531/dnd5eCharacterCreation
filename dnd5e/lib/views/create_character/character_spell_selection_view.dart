import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/character_repository.dart';
import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart'
    as inv_vm;
import '../../views/create_character/character_inventory_view.dart' as inv_view;
import '../../widgets/create_character_view/spell_selection_view.dart/magic_stat_bar.dart';
import '../../widgets/create_character_view/spell_selection_view.dart/spell_level_tab.dart';
import '../../../utils/app_theme.dart';

class CharacterSpellSelectionView extends StatefulWidget {
  const CharacterSpellSelectionView({super.key});
  @override
  State<CharacterSpellSelectionView> createState() =>
      _CharacterSpellSelectionViewState();
}

class _CharacterSpellSelectionViewState
    extends State<CharacterSpellSelectionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<int> _availableLevels = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final spellVM = context.read<CharacterSpellViewModel>();
      final characterVM = context.read<CreateCharacterViewModel>();
      final dndClass = characterVM.selectedClass?.name ?? '';
      spellVM.loadSpells(dndClass);
      _setupTabs();
    });
  }

  void _setupTabs() {
    final vm = context.read<CreateCharacterViewModel>();
    final spellVM = context.read<CharacterSpellViewModel>();
    final cls = vm.selectedClass;
    if (cls == null) return;

    final info = spellVM.parseSpellcastingInfo(cls.table, cls.slug, vm.level);
    if (info == null) return;

    final levels = <int>[];
    if (info.cantripsKnown > 0) levels.add(0);
    for (int i = 0; i < 9; i++) {
      if (info.slotsPerLevel[i] > 0) levels.add(i + 1);
    }
    if (cls.slug == 'warlock' && info.warlockSlotLevel > 0) {
      for (int i = 1; i <= info.warlockSlotLevel; i++) {
        if (!levels.contains(i)) levels.add(i);
      }
    }
    levels.sort();

    setState(() {
      _availableLevels = levels;
      _tabController = TabController(length: levels.length, vsync: this);
    });
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
  void dispose() {
    _searchController.dispose();
    if (_availableLevels.isNotEmpty) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final spellVM = context.watch<CharacterSpellViewModel>();
    final cls = vm.selectedClass;

    if (cls == null || !spellVM.isSpellcaster(cls.slug)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spells'),
          backgroundColor: AppTheme.primaryRed,
        ),
        body: const Center(
          child: Text(
            'This class does not have spellcasting.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final info = spellVM.parseSpellcastingInfo(cls.table, cls.slug, vm.level);

    if (info == null || !info.hasSpells) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spells'),
          backgroundColor: AppTheme.primaryRed,
        ),
        body: const Center(
          child: Text(
            'No spell slots available at this level.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final spellAbility = cls.spellcasting_ability;
    final spellMod = vm.getModifier(spellAbility);
    final profBonus = CreateCharacterViewModel.proficiencyBonus(vm.level);
    final spellAttackBonus = profBonus + spellMod;
    final saveDC = 8 + profBonus + spellMod;

    int spellsKnown;
    if (spellVM.usesDynamicFormula(cls.slug)) {
      spellsKnown = spellVM.dynamicSpellsKnown(cls.slug, vm.level, spellMod);
      if (spellsKnown < 1) spellsKnown = 1;
    } else {
      spellsKnown = info.spellsKnown ?? 0;
    }

    if (_availableLevels.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Spell Selection: '
          '${cls.slug[0].toUpperCase()}${cls.slug.substring(1)} '
          'Lv${vm.level}',
        ),
        backgroundColor: AppTheme.primaryRed,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: _availableLevels.map((lvl) {
            final sel = lvl == 0
                ? spellVM.totalCantripsSelected
                : spellVM.totalNonCantripSelected;
            final max = lvl == 0 ? info.cantripsKnown : spellsKnown;
            return Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lvl == 0 ? 'Cantrips' : 'Level $lvl',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: sel >= max
                          ? Colors.red.withOpacity(0.5)
                          : Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$sel/$max',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),

      // ── Bottom bar con resumen + botón de inventario ──────────────────────
      bottomNavigationBar: _buildBottomBar(vm, spellVM),

      body: Column(
        children: [
          // ── Panel de stats mágicos ─────────────────────────────────────
          magicStatsBar(
            cls.slug,
            spellAbility,
            spellMod,
            spellAttackBonus,
            saveDC,
            spellsKnown,
            spellVM.totalSelectedAcrossAllLevels(),
            info,
            spellVM,
          ),

          // ── Búsqueda ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search spells...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          spellVM.setSearchQuery('');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: spellVM.setSearchQuery,
            ),
          ),

          // ── Lista de hechizos por tab ──────────────────────────────────
          Expanded(
            child: spellVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _availableLevels.map((spellLevel) {
                      return SpellLevelTab(
                        spellLevel: spellLevel,
                        classSlug: cls.slug,
                        globalSpellsMax: spellsKnown,
                        cantripsMax: info.cantripsKnown,
                        spellVM: spellVM,
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar — DENTRO de la clase para tener acceso a context y métodos──
  Widget _buildBottomBar(
    CreateCharacterViewModel vm,
    CharacterSpellViewModel spellVM,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen compacto de selecciones
            Text(
              '${spellVM.totalCantripsSelected} cantrip'
              '${spellVM.totalCantripsSelected != 1 ? 's' : ''}  ·  '
              '${spellVM.totalNonCantripSelected} spell'
              '${spellVM.totalNonCantripSelected != 1 ? 's' : ''} selected',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // ✅ Llama al método del State — tiene acceso a context
                onPressed: () => _goToInventory(vm),
                icon: const Icon(Icons.backpack, size: 20),
                label: const Text(
                  'Continue to Inventory',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
