import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/providers/character_sheet_storage.dart';
import '../create_character/pdf_viewer_view.dart';
import '../create_character/race_selector_view.dart';
import '../../utils/app_theme.dart';

class CharacterTab extends StatefulWidget {
  const CharacterTab({super.key});

  @override
  State<CharacterTab> createState() => _CharacterTabState();
}

class _CharacterTabState extends State<CharacterTab> {
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = true;
  List<SavedCharacterSheet> _sheets = [];

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

    final sheets = await CharacterSheetStorage.listSheets();

    if (!mounted) return;

    setState(() {
      _sheets = sheets;
      _isLoading = false;
    });
  }

  List<SavedCharacterSheet> get _filteredSheets {
    final query = _searchCtrl.text.trim().toLowerCase();

    if (query.isEmpty) return _sheets;

    return _sheets.where((sheet) {
      return sheet.displayName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openCreateFlow() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RaceSelectionView(),
      ),
    );

    await _loadSheets();
  }

  Future<void> _deleteSheet(SavedCharacterSheet sheet) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete PDF'),
        content: Text('Delete "${sheet.displayName}"?'),
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final sheet = sheets[index];
                              final exists = File(sheet.path).existsSync();

                              return Card(
                                elevation: 2,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.picture_as_pdf,
                                    color: exists
                                        ? context.colors.primary
                                        : context.dndColors.subtleText,
                                  ),
                                  title: Text(
                                    sheet.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${_formatDate(sheet.modifiedAt)} • ${_formatSize(sheet.sizeBytes)}',
                                  ),
                                  onTap: exists
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PdfViewerView(
                                                filePath: sheet.path,
                                                title:
                                                    '${sheet.displayName} — Sheet',
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'open' && exists) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PdfViewerView(
                                              filePath: sheet.path,
                                              title:
                                                  '${sheet.displayName} — Sheet',
                                            ),
                                          ),
                                        );
                                      }

                                      if (value == 'share' && exists) {
                                        Share.shareXFiles(
                                          [XFile(sheet.path)],
                                          subject: sheet.displayName,
                                        );
                                      }

                                      if (value == 'delete') {
                                        _deleteSheet(sheet);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'open',
                                        child: Text('Open'),
                                      ),
                                      PopupMenuItem(
                                        value: 'share',
                                        child: Text('Share'),
                                      ),
                                      PopupMenuItem(
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