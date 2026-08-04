import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/character/character_detail_class_view_model.dart';
import '../../../view_models/character/character_subclass_view_model.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../views/create_character/character_details_view.dart';
import '../../../views/create_character/detail_class_view.dart';

class StatsBottomButton extends StatelessWidget {
  const StatsBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: vm.isLevelUpComplete
            ? () => _continue(context, vm)
            : null,
        child: Text(
          vm.isLevelUpComplete
              ? vm.isLevelUp
                  ? 'Continue Level Up'
                  : 'Continue to Skills & Equipment'
              : 'Complete all Level Improvements to continue',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _continue(
    BuildContext context,
    CreateCharacterViewModel vm,
  ) {
    if (!vm.isLevelUp) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CharacterSkillAndEquipmentView(),
        ),
      );
      return;
    }

    final saved = vm.levelUpState;
    if (saved == null) return;

    final detailVM = DetailClassViewModel();
    detailVM.restoreProgression(
      hpRolls: saved.hpRolls,
      selectedArchetype: saved.selectedArchetype,
      selectedFightingStyle: saved.selectedFightingStyle,
      selectedFightingStyleName: saved.selectedFightingStyleName,
    );

    final subclassVM = CharacterSubclassViewModel(
      detailClassVM: detailVM,
      skillVM: vm.skillVM,
    );

    final existingSkills = <String>{
      ...vm.skillVM.classFixedSkills,
      ...vm.skillVM.bgFixedSkills,
      ...vm.skillVM.selectedClassSkills,
      ...vm.racialSkillProficiencies,
    }.toList();

    subclassVM.restoreProgression(
      archetype: saved.selectedArchetype,
      existingSkills: existingSkills,
      selectedBonusSkills: saved.selectedBonusSkills,
      selectedSpellTableId: saved.selectedSpellTableId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: detailVM),
            ChangeNotifierProvider.value(value: subclassVM),
          ],
          child: const DetailClassView(),
        ),
      ),
    );
  }
}
