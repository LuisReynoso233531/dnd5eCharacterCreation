import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/character/character_view_model.dart';
import '../../../views/create_character/character_details_view.dart';
import '../../../utils/app_theme.dart';

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
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: vm.isLevelUpComplete
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CharacterSkillAndEquipmentView()),
                );
              }
            : null,
        child: Text(
          vm.isLevelUpComplete
              ? "Continue to Skills & Equipment"
              : "Complete all Level Improvements to continue",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}