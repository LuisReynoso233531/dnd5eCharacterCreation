import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/character_repository.dart';
import '../../utils/app_theme.dart';
import '../../utils/spellcasting_source.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart'
    as inv_vm;
import '../../view_models/character/character_spell_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../view_models/character/character_view_model.dart';
import '../../views/create_character/character_inventory_view.dart' as inv_view;
import '../../widgets/create_character_view/spell_selection_view.dart/magic_stat_bar.dart';
import '../../widgets/create_character_view/spell_selection_view.dart/spell_level_tab.dart';

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
  final List<int> _availableLevels = [];

  SpellcastingSource? _source;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final spellVM = context.read<CharacterSpellViewModel>();
      final characterVM = context.read<CreateCharacterViewModel>();
      final detailVM = context.read<DetailClassViewModel>();
      final subclassVM = context.read<CharacterSubclassViewModel>();
      final characterClass = characterVM.selectedClass;

      if (characterClass == null) return;

      final source = SpellcastingSourceResolver.resolve(
        characterClass: characterClass,
        characterLevel: characterVM.level,
        archetype: detailVM.selectedArchetype,
      );

      if (source == null) return;
      _source = source;

      await spellVM.loadSpells(
        source.apiClassName,
        automaticGrants: subclassVM.grantedSpellsForLevel(characterVM.level),
        preferredDocumentSlug:
            detailVM.selectedArchetype?['document__slug']?.toString(),
      );

      if (!mounted) return;
      _setupTabs(source);
    });
  }

  void _setupTabs(SpellcastingSource source) {
    final vm = context.read<CreateCharacterViewModel>();
    final spellVM = context.read<CharacterSpellViewModel>();

    final info = spellVM.parseSpellcastingInfo(
      source.table,
      source.rulesSlug,
      vm.level,
    );
    if (info == null) return;

    final levels = <int>[];

    if (info.cantripsKnown > 0) levels.add(0);

    for (int i = 0; i < info.slotsPerLevel.length; i++) {
      if (info.slotsPerLevel[i] > 0) levels.add(i + 1);
    }

    if (source.rulesSlug == 'warlock' && info.warlockSlotLevel > 0) {
      for (int i = 1; i <= info.warlockSlotLevel; i++) {
        if (!levels.contains(i)) levels.add(i);
      }
    }

    for (final spell in spellVM.getAutomaticSpellModels()) {
      if (!levels.contains(spell.levelInt)) {
        levels.add(spell.levelInt);
      }
    }

    levels.sort();
    if (levels.isEmpty) return;

    setState(() {
      _availableLevels
        ..clear()
        ..addAll(levels);
      _tabController = TabController(length: levels.length, vsync: this);
    });
  }

  void _goToInventory(CreateCharacterViewModel vm) {
    final detailVM = context.read<DetailClassViewModel>();
    final subclassVM = context.read<CharacterSubclassViewModel>();
    final spellVM = context.read<CharacterSpellViewModel>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: detailVM),
            ChangeNotifierProvider.value(value: subclassVM),
            ChangeNotifierProvider.value(value: spellVM),
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
  void dispose() {
    _searchController.dispose();
    if (_availableLevels.isNotEmpty) _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final spellVM = context.watch<CharacterSpellViewModel>();
    final detailVM = context.watch<DetailClassViewModel>();
    final characterClass = vm.selectedClass;

    final source = characterClass == null
        ? null
        : _source ??
              SpellcastingSourceResolver.resolve(
                characterClass: characterClass,
                characterLevel: vm.level,
                archetype: detailVM.selectedArchetype,
              );

    if (characterClass == null || source == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spells'),
          ),
        body: Center(
          child: Text(
            'This class or subclass does not have spellcasting at this level.',
            style: TextStyle(color: context.dndColors.mutedText),
          ),
        ),
      );
    }

    final info = spellVM.parseSpellcastingInfo(
      source.table,
      source.rulesSlug,
      vm.level,
    );

    if (info == null || !source.hasSpellSelectionAtLevel(vm.level)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spells'),
          ),
        body: Center(
          child: Text(
            'No spells are available at this level.',
            style: TextStyle(color: context.dndColors.mutedText),
          ),
        ),
      );
    }

    final spellAbility = source.ability;
    final spellMod = vm.getModifier(spellAbility);
    final profBonus = CreateCharacterViewModel.proficiencyBonus(vm.level);
    final spellAttackBonus = profBonus + spellMod;
    final saveDC = 8 + profBonus + spellMod;

    int spellsKnown;
    if (spellVM.usesDynamicFormula(source.rulesSlug)) {
      spellsKnown = spellVM.dynamicSpellsKnown(
        source.rulesSlug,
        vm.level,
        spellMod,
      );
      if (spellsKnown < 1) spellsKnown = 1;
    } else {
      spellsKnown = info.spellsKnown ?? 0;
    }

    if (_availableLevels.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Spell Selection: ${source.displayName} Lv${vm.level}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: _availableLevels.map((level) {
            final selected = level == 0
                ? spellVM.totalCantripsTowardLimit
                : spellVM.totalNonCantripsTowardLimit;
            final maximum = level == 0 ? info.cantripsKnown : spellsKnown;

            return Tab(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level == 0 ? 'Cantrips' : 'Level $level',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected >= maximum
                          ? Colors.red.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selected/$maximum',
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
      bottomNavigationBar: _buildBottomBar(context, vm, spellVM),
      body: Column(
        children: [
          magicStatsBar(
            context,
            source.rulesSlug,
            spellAbility,
            spellMod,
            spellAttackBonus,
            saveDC,
            spellsKnown,
            spellVM.totalSelectedAcrossAllLevels(),
            info,
            spellVM,
          ),
          if (spellVM.unresolvedAutomaticSpellNames.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: context.dndColors.warningContainer,
              child: Text(
                'Could not find these granted spells in the API: '
                '${spellVM.unresolvedAutomaticSpellNames.join(', ')}',
                style: TextStyle(
                  color: context.dndColors.onWarningContainer,
                  fontSize: 11,
                ),
              ),
            ),
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
          Expanded(
            child: spellVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _availableLevels.map((spellLevel) {
                      return SpellLevelTab(
                        spellLevel: spellLevel,
                        classSlug: source.spellListSlug,
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

  Widget _buildBottomBar(
    BuildContext context,
    CreateCharacterViewModel vm,
    CharacterSpellViewModel spellVM,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${spellVM.totalCantripsTowardLimit} cantrip'
              '${spellVM.totalCantripsTowardLimit != 1 ? 's' : ''}  ·  '
              '${spellVM.totalNonCantripsTowardLimit} spell'
              '${spellVM.totalNonCantripsTowardLimit != 1 ? 's' : ''} selected'
              '${spellVM.totalAutomaticSpells > 0 ? '  ·  ${spellVM.totalAutomaticSpells} granted' : ''}',
              style: TextStyle(color: context.dndColors.mutedText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.dndColors.success,
                  foregroundColor: context.dndColors.onSuccess,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
