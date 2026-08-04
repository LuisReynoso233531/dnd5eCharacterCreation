import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/saved_character_state.dart';
import '../../data/providers/character_progression_storage.dart';
import '../../data/providers/character_sheet_storage.dart';
import '../../utils/app_theme.dart';
import '../../view_models/character/character_view_model.dart';
import '../create_character/character_stats_view.dart';
import '../create_character/pdf_viewer_view.dart';
import '../create_character/race_selector_view.dart';

class CharacterTab extends StatefulWidget {
  const CharacterTab({super.key});

  @override
  State<CharacterTab> createState() => _CharacterTabState();
}

class _CharacterTabState extends State<CharacterTab> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = true;
  List<SavedCharacterSheet> _sheets = [];
  Map<String, SavedCharacterState> _charactersByPdf = {};

  @override
  void initState() {
    super.initState();
    _loadSheets();

    _searchCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSheets() async {
    setState(() => _isLoading = true);

    final sheetsFuture = CharacterSheetStorage.listSheets();
    final charactersFuture = CharacterProgressionStorage.listCharacters();
    final sheets = await sheetsFuture;
    final characters = await charactersFuture;

    if (!mounted) return;

    setState(() {
      _sheets = sheets;
      _charactersByPdf = {
        for (final character in characters)
          if (character.currentPdfPath?.trim().isNotEmpty == true)
            character.currentPdfPath!: character,
      };
      _isLoading = false;
    });
  }

  List<SavedCharacterSheet> get _filteredSheets {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) return _sheets;

    return _sheets.where((sheet) {
      final character = _charactersByPdf[sheet.path];
      return sheet.displayName.toLowerCase().contains(query) ||
          (character?.name.toLowerCase().contains(query) ?? false) ||
          (character?.className.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _openCreateFlow() async {
    context.read<CreateCharacterViewModel>().resetCreation();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RaceSelectionView()),
    );

    await _loadSheets();
  }

  Future<void> _startLevelUp(SavedCharacterState character) async {
    if (!character.canLevelUp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This character is already level 20.')),
      );
      return;
    }

    final isCurrentVersion = character.isCurrentVersion;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isCurrentVersion ? 'Level Up' : 'Level Up From This Version',
        ),
        content: Text(
          'Advance ${character.name} from level ${character.level} '
          'to level ${character.level + 1}?\n\n'
          '${isCurrentVersion ? 'The current version' : 'This saved version'} '
          'will remain unchanged. Completing the flow creates a new saved '
          'character version and a new PDF.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.trending_up),
            label: Text(isCurrentVersion ? 'Level Up' : 'Create New Version'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await context.read<CreateCharacterViewModel>().beginLevelUp(character);
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CharacterStatsView()),
    );

    await _loadSheets();
  }

  Future<void> _deleteSheet(SavedCharacterSheet sheet) async {
    final character = _charactersByPdf[sheet.path];
    final isSavedVersion = character != null;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSavedVersion ? 'Delete Saved Version' : 'Delete PDF'),
        content: Text(
          isSavedVersion
              ? 'Delete ${character.name} level ${character.level} and its '
                    'saved level-up data? Other saved versions of this '
                    'character will remain available.'
              : 'Delete "${sheet.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await CharacterSheetStorage.deleteSheet(sheet.path);

    if (character != null) {
      await CharacterProgressionStorage.deleteCharacterData(character.id);
    }

    await _loadSheets();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final sheets = _filteredSheets;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSheets,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _openCreateFlow,
                    icon: const Icon(Icons.add),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search characters...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : sheets.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text(
                              'No characters yet. Tap Create to start!',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        itemCount: sheets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final sheet = sheets[index];
                          final exists = File(sheet.path).existsSync();
                          final character = _charactersByPdf[sheet.path];

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(
                                character == null
                                    ? Icons.picture_as_pdf
                                    : Icons.person_outline,
                                color: exists
                                    ? context.colors.primary
                                    : context.dndColors.subtleText,
                              ),
                              title: Text(
                                character?.name ?? sheet.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                character == null
                                    ? '${_formatDate(sheet.modifiedAt)} • '
                                          '${_formatSize(sheet.sizeBytes)} • '
                                          'Legacy PDF'
                                    : '${character.className} '
                                          'Level ${character.level} • '
                                          '${character.isCurrentVersion ? 'Current version' : 'Previous version'} • '
                                          '${_formatDate(sheet.modifiedAt)} • '
                                          '${_formatSize(sheet.sizeBytes)}',
                              ),
                              onTap: exists
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfViewerView(
                                            filePath: sheet.path,
                                            title:
                                                '${character?.name ?? sheet.displayName} — Sheet',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  if (value == 'open' && exists) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PdfViewerView(
                                          filePath: sheet.path,
                                          title:
                                              '${character?.name ?? sheet.displayName} — Sheet',
                                        ),
                                      ),
                                    );
                                  }

                                  if (value == 'levelUp' && character != null) {
                                    await _startLevelUp(character);
                                  }

                                  if (value == 'share' && exists) {
                                    await Share.shareXFiles(
                                      [XFile(sheet.path)],
                                      subject:
                                          character?.name ?? sheet.displayName,
                                    );
                                  }

                                  if (value == 'delete') {
                                    await _deleteSheet(sheet);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'open',
                                    child: Text('Open'),
                                  ),
                                  if (character != null)
                                    PopupMenuItem(
                                      value: 'levelUp',
                                      enabled: character.canLevelUp,
                                      child: Text(
                                        character.canLevelUp
                                            ? character.isCurrentVersion
                                                  ? 'Level Up'
                                                  : 'Level Up from here'
                                            : 'Maximum Level',
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Text('Share'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
