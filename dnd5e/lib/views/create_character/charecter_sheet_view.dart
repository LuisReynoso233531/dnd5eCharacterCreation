import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../view_models/character/character_spell_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../data/providers/character_sheet_service.dart';
import '../../../utils/app_theme.dart';
import '../../../views/create_character/pdf_viewer_view.dart';

import '../../widgets/create_character_view/character_sheet_view/character_sheet_summary_card.dart';
import '../../widgets/create_character_view/character_sheet_view/character_sheet_checklist_card.dart';
import '../../widgets/create_character_view/character_sheet_view/character_sheet_input_field.dart';
import '../../widgets/create_character_view/character_sheet_view/character_sheet_feedback_cards.dart';

const _kSheetAsset = 'assets/sheets/5E_CharacterSheet_Fillable.pdf';

class CharacterSheetView extends StatefulWidget {
  final CharacterInventoryViewModel invVM;
  final DetailClassViewModel? detailVM;
  final CharacterSubclassViewModel? subclassVM;
  final CharacterSpellViewModel? spellVM;

  const CharacterSheetView({
    super.key,
    required this.invVM,
    this.detailVM,
    this.subclassVM,
    this.spellVM,
  });

  @override
  State<CharacterSheetView> createState() => _CharacterSheetViewState();
}

class _CharacterSheetViewState extends State<CharacterSheetView> {
  late final TextEditingController _characterNameCtrl;
  late final TextEditingController _playerNameCtrl;
  late final TextEditingController _alignmentCtrl;
  late final TextEditingController _tempHpCtrl;
  late final TextEditingController _personalityCtrl;
  late final TextEditingController _idealsCtrl;
  late final TextEditingController _bondsCtrl;
  late final TextEditingController _flawsCtrl;

  bool _isGenerating = false;
  bool _loadedInitialName = false;
  String? _generatedPath;
  String? _error;

  @override
  void initState() {
    super.initState();

    _characterNameCtrl = TextEditingController();
    _playerNameCtrl = TextEditingController();
    _alignmentCtrl = TextEditingController();
    _tempHpCtrl = TextEditingController();
    _personalityCtrl = TextEditingController();
    _idealsCtrl = TextEditingController();
    _bondsCtrl = TextEditingController();
    _flawsCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedInitialName) return;

    _characterNameCtrl.text = context.read<CreateCharacterViewModel>().name;
    _loadedInitialName = true;
  }

  @override
  void dispose() {
    _characterNameCtrl.dispose();
    _playerNameCtrl.dispose();
    _alignmentCtrl.dispose();
    _tempHpCtrl.dispose();
    _personalityCtrl.dispose();
    _idealsCtrl.dispose();
    _bondsCtrl.dispose();
    _flawsCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    final isReady =
        vm.selectedClass != null &&
        vm.selectedRace != null &&
        vm.isDwarvenToolProficiencyComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Sheet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CharacterSheetSummaryCard(
              vm: vm,
              invVM: widget.invVM,
              detailVM: widget.detailVM,
            ),
            const SizedBox(height: 20),

            CharacterSheetChecklistCard(vm: vm),
            const SizedBox(height: 20),

            _sectionTitle('Personal Information'),
            const SizedBox(height: 10),
            _personalInformationFields(vm),
            const SizedBox(height: 20),

            _sectionTitle('Personality & Backstory'),
            const SizedBox(height: 10),
            _personalityFields(),
            const SizedBox(height: 20),

            if (_error != null) ...[
              CharacterSheetErrorCard(message: _error!),
              const SizedBox(height: 12),
            ],

            _generateButton(vm, isReady),

            if (!isReady) ...[
              const SizedBox(height: 8),
              Text(
                vm.isDwarvenToolProficiencyComplete
                    ? 'Select a race and class to generate the sheet.'
                    : 'Choose the required dwarven tool proficiency first.',
                style: TextStyle(
                  color: context.dndColors.mutedText,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (_generatedPath != null) ...[
              const SizedBox(height: 20),
              CharacterSheetSuccessCard(
                path: _generatedPath!,
                characterName: vm.name,
                onPreview: () => _openPreview(vm),
                onShare: _sharePdf,
                onRegenerate: () => _generate(vm),
                onGoHome: _goHome,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _openPreview(CreateCharacterViewModel vm) {
  if (_generatedPath == null) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PdfViewerView(
        filePath: _generatedPath!,
        title: vm.name.isNotEmpty ? '${vm.name} — Sheet' : 'Character Sheet',
        showHomeButton: true,
      ),
    ),
  );
}

  Widget _personalInformationFields(CreateCharacterViewModel vm) {
    return Column(
      children: [
        CharacterSheetInputField(
          controller: _characterNameCtrl,
          label: 'Character Name',
          icon: Icons.badge,
          onChanged: vm.setName,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CharacterSheetInputField(
                controller: _playerNameCtrl,
                label: 'Player Name',
                icon: Icons.person,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CharacterSheetInputField(
                controller: _alignmentCtrl,
                label: 'Alignment',
                icon: Icons.balance,
                hint: 'e.g. Chaotic Good',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CharacterSheetInputField(
          controller: _tempHpCtrl,
          label: 'Temporary HP',
          icon: Icons.favorite_border,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _personalityFields() {
    return Column(
      children: [
        CharacterSheetInputField(
          controller: _personalityCtrl,
          label: 'Personality Traits',
          icon: Icons.psychology,
          maxLines: 3,
          hint: 'How does your character behave?',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CharacterSheetInputField(
                controller: _idealsCtrl,
                label: 'Ideals',
                icon: Icons.star,
                maxLines: 3,
                hint: 'What drives you?',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CharacterSheetInputField(
                controller: _bondsCtrl,
                label: 'Bonds',
                icon: Icons.link,
                maxLines: 3,
                hint: 'What connects you to the world?',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CharacterSheetInputField(
          controller: _flawsCtrl,
          label: 'Flaws',
          icon: Icons.warning_amber,
          maxLines: 2,
          hint: 'What are your weaknesses?',
        ),
      ],
    );
  }

  Widget _generateButton(CreateCharacterViewModel vm, bool isReady) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? context.colors.primary : null,
          foregroundColor: isReady ? context.colors.onPrimary : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: (isReady && !_isGenerating) ? () => _generate(vm) : null,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.picture_as_pdf, size: 22),
        label: Text(
          _isGenerating ? 'Generating...' : 'Generate Character Sheet',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _generate(CreateCharacterViewModel vm) async {
    final characterName = _characterNameCtrl.text.trim();

    if (characterName.isNotEmpty) {
      vm.setName(characterName);
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _generatedPath = null;
    });

    try {
      final data = CharacterSheetService.buildData(
        vm: vm,
        invVM: widget.invVM,
        spellVM: widget.spellVM,
        detailVM: widget.detailVM,
        subclassVM: widget.subclassVM,
        playerName: _playerNameCtrl.text.trim(),
        alignment: _alignmentCtrl.text.trim(),
        temporaryHp: _tempHpCtrl.text.trim(),
        personalityTraits: _personalityCtrl.text.trim(),
        ideals: _idealsCtrl.text.trim(),
        bonds: _bondsCtrl.text.trim(),
        flaws: _flawsCtrl.text.trim(),
      );

      final path = await CharacterSheetService.generatePdf(
        d: data,
        blankPdfAssetPath: _kSheetAsset,
      );

      if (!mounted) return;

      setState(() {
        _generatedPath = path;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Character sheet generated!',
            style: TextStyle(color: context.dndColors.onSuccessContainer),
          ),
          backgroundColor: context.dndColors.successContainer,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

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
      subject: 'D&D 5e Character Sheet',
      text: 'My D&D 5e character sheet',
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
