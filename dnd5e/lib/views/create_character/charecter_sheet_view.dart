import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';
import '../../data/providers/character_sheet_service.dart';
import '../../../utils/app_theme.dart';

// ─── Blank PDF asset path (add to pubspec.yaml assets) ────────────────────
// assets/sheets/5E_CharacterSheet_Fillable.pdf
const _kSheetAsset = 'assets/sheets/5E_CharacterSheet_Fillable.pdf';

class CharacterSheetView extends StatefulWidget {
  const CharacterSheetView({super.key});
  @override
  State<CharacterSheetView> createState() => _CharacterSheetViewState();
}

class _CharacterSheetViewState extends State<CharacterSheetView> {
  bool _isGenerating = false;
  String? _generatedPath;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    // Optional sub-VMs — may not be in tree if user skipped those screens
    final invVM = _tryRead<CharacterInventoryViewModel>(context);
    final spellVM = _tryRead<CharacterSpellViewModel>(context);

    final hasClass = vm.selectedClass != null;
    final hasRace = vm.selectedRace != null;
    final hasName = vm.name.isNotEmpty;
    final isReady = hasClass && hasRace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Sheet'),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Character summary card ─────────────────────────────────────
            _SummaryCard(vm: vm),
            const SizedBox(height: 24),

            // ── Completeness checklist ─────────────────────────────────────
            _ChecklistCard(vm: vm),
            const SizedBox(height: 24),

            // ── Error message ──────────────────────────────────────────────
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            // ── Generate button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReady ? AppTheme.primaryRed : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (isReady && !_isGenerating)
                    ? () => _generate(vm, invVM, spellVM)
                    : null,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf, size: 22),
                label: Text(
                  _isGenerating
                      ? 'Generating...'
                      : 'Generate Character Sheet',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            if (!isReady) ...[
              const SizedBox(height: 8),
              Text(
                'Complete your character (name, race, class) to generate the sheet.',
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Success — share/open buttons ───────────────────────────────
            if (_generatedPath != null) ...[
              const SizedBox(height: 20),
              _SuccessCard(
                path: _generatedPath!,
                characterName: vm.name,
                onShare: _sharePdf,
                onRegenerate: () => _generate(vm, invVM, spellVM),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _generate(
    CreateCharacterViewModel vm,
    CharacterInventoryViewModel? invVM,
    CharacterSpellViewModel? spellVM,
  ) async {
    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedPath = null;
    });

    try {
      final data = CharacterSheetService.buildData(
        vm: vm,
        invVM: invVM,
        spellVM: spellVM,
      );

      final path = await CharacterSheetService.generatePdf(
        d: data,
        blankPdfAssetPath: _kSheetAsset,
      );

      setState(() {
        _generatedPath = path;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Character sheet generated!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to generate: $e';
        _isGenerating = false;
      });
    }
  }

  void _sharePdf() {
    if (_generatedPath == null) return;
    Share.shareXFiles(
      [XFile(_generatedPath!)],
      subject: 'D&D Character Sheet',
      text: 'My D&D 5e character sheet',
    );
  }

  // Safe read — returns null if not in Provider tree
  T? _tryRead<T extends ChangeNotifier>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final CreateCharacterViewModel vm;
  const _SummaryCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final profBonus =
        CreateCharacterViewModel.proficiencyBonus(vm.level);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryRed.withOpacity(0.85),
            AppTheme.primaryRed.withOpacity(0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.name.isNotEmpty ? vm.name : '(Unnamed Character)',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (vm.selectedClass != null)
                _chip('${vm.selectedClass!.name} ${vm.level}',
                    Icons.military_tech),
              if (vm.selectedRace != null)
                _chip(vm.selectedRace!['name'] ?? '', Icons.face),
              if (vm.selectedBackground != null)
                _chip(vm.selectedBackground!['name'] ?? '',
                    Icons.history_edu),
              _chip('HP: ${vm.maxHp}', Icons.favorite),
              _chip('Prof: +$profBonus', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ],
        ),
      );
}

// ─── Checklist Card ───────────────────────────────────────────────────────────
class _ChecklistCard extends StatelessWidget {
  final CreateCharacterViewModel vm;
  const _ChecklistCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Check('Name', vm.name.isNotEmpty),
      _Check('Race', vm.selectedRace != null),
      _Check('Class', vm.selectedClass != null),
      _Check('Background', vm.selectedBackground != null),
      _Check('Level improvements',
          vm.isLevelUpComplete || vm.availableImprovementLevels.isEmpty),
      _Check('Skills selected',
          vm.skillVM.selectedClassSkills.isNotEmpty ||
              vm.skillVM.totalFixedSkills().isNotEmpty),
    ];

    final done = items.where((i) => i.done).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Character Completeness',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              Text('$done/${items.length}',
                  style: TextStyle(
                      color: done == items.length
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: done / items.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                  done == items.length ? Colors.green : Colors.orange),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Icon(
                      item.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: item.done ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: item.done
                            ? Colors.black87
                            : Colors.grey,
                        decoration: item.done
                            ? null
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Check {
  final String label;
  final bool done;
  _Check(this.label, this.done);
}

// ─── Success Card ─────────────────────────────────────────────────────────────
class _SuccessCard extends StatelessWidget {
  final String path;
  final String characterName;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;

  const _SuccessCard({
    required this.path,
    required this.characterName,
    required this.onShare,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = path.split('/').last;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Sheet Generated!',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontFamily: 'monospace'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}