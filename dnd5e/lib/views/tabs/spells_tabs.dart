import 'package:dnd5e/data/models/spell_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/spell/spells_view_model.dart';
import '../../widgets/create_character_view/spell_selection_view.dart/spell_card.dart';

class SpellsTab extends StatelessWidget {
  const SpellsTab({super.key});

  static const List<String> _tabTitles = [
    'Cantrips',
    'Level 1',
    'Level 2',
    'Level 3',
    'Level 4',
    'Level 5',
    'Level 6',
    'Level 7',
    'Level 8',
    'Level 9',
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellsViewModel>();

    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spell Compendium'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Cantrips'),
              Tab(text: 'Level 1'),
              Tab(text: 'Level 2'),
              Tab(text: 'Level 3'),
              Tab(text: 'Level 4'),
              Tab(text: 'Level 5'),
              Tab(text: 'Level 6'),
              Tab(text: 'Level 7'),
              Tab(text: 'Level 8'),
              Tab(text: 'Level 9'),
            ],
          ),
        ),
        body: Column(
          children: [
            _SearchAndFilterBar(
              viewModel: viewModel,
              onOpenClassFilter: () {
                _showClassFilter(
                  context,
                  viewModel,
                );
              },
            ),
            if (viewModel.selectedClasses.isNotEmpty)
              _SelectedClassFilters(
                viewModel: viewModel,
              ),
            Expanded(
              child: _buildContent(
                context,
                viewModel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SpellsViewModel viewModel,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return _SpellErrorView(
        message: viewModel.errorMessage!,
        onRetry: viewModel.loadSpells,
      );
    }

    return TabBarView(
      children: List.generate(
        _tabTitles.length,
        (level) {
          final spells = viewModel.spellsForLevel(level);

          if (spells.isEmpty) {
            return _EmptySpellsView(
              hasClassFilters:
                  viewModel.selectedClasses.isNotEmpty,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              12,
              6,
              12,
              16,
            ),
            itemCount: spells.length,
            itemBuilder: (context, index) {
              final rawSpell =
                  Map<String, dynamic>.from(
                spells[index],
              );

              return SpellCard(
                spell: SpellModel.fromJson(rawSpell),
                isCompendiumMode: true,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showClassFilter(
    BuildContext context,
    SpellsViewModel viewModel,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: const _ClassFilterSheet(),
        );
      },
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.viewModel,
    required this.onOpenClassFilter,
  });

  final SpellsViewModel viewModel;
  final VoidCallback onOpenClassFilter;

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      onChanged: viewModel.setSearchQuery,
      decoration: const InputDecoration(
        hintText: 'Search spells...',
        prefixIcon: Icon(Icons.search),
      ),
    );

    final classFilterButton = OutlinedButton.icon(
      onPressed: onOpenClassFilter,
      icon: const Icon(Icons.filter_list),
      label: Text(
        viewModel.selectedClasses.isEmpty
            ? 'Classes'
            : 'Classes (${viewModel.selectedClasses.length})',
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        6,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 8),
                classFilterButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: searchField),
              const SizedBox(width: 10),
              classFilterButton,
            ],
          );
        },
      ),
    );
  }
}

class _SelectedClassFilters extends StatelessWidget {
  const _SelectedClassFilters({
    required this.viewModel,
  });

  final SpellsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final selectedClasses = viewModel.selectedClasses.toList()
      ..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        8,
      ),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...selectedClasses.map(
            (className) => InputChip(
              label: Text(className),
              onDeleted: () {
                viewModel.toggleClass(className);
              },
            ),
          ),
          ActionChip(
            avatar: const Icon(
              Icons.clear_all,
              size: 18,
            ),
            label: const Text('Clear'),
            onPressed: viewModel.clearClassFilters,
          ),
        ],
      ),
    );
  }
}

class _ClassFilterSheet extends StatelessWidget {
  const _ClassFilterSheet();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellsViewModel>();
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 720,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filter by class',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (viewModel.selectedClasses.isNotEmpty)
                  TextButton(
                    onPressed:
                        viewModel.clearClassFilters,
                    child: const Text('Clear all'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select one or more classes. A spell is shown when '
              'it belongs to at least one selected class.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.availableClasses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Center(
                  child: Text(
                    'No class information was found.',
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        viewModel.availableClasses.map(
                      (className) {
                        return FilterChip(
                          label: Text(className),
                          selected: viewModel
                              .isClassSelected(className),
                          onSelected: (_) {
                            viewModel.toggleClass(
                              className,
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySpellsView extends StatelessWidget {
  const _EmptySpellsView({
    required this.hasClassFilters,
  });

  final bool hasClassFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          hasClassFilters
              ? 'No spells match the selected classes '
                  'at this level.'
              : 'No spells found.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _SpellErrorView extends StatelessWidget {
  const _SpellErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
            const Text(
              'The spells could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}