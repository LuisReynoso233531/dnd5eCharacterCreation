import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../widgets/create_character_view/detail_view/sections/skills_section.dart';
import '../../widgets/create_character_view/detail_view/sections/equipment_section.dart';
import '../../widgets/create_character_view/detail_view/sections/language_section.dart';
import '../../widgets/create_character_view/detail_view/section_title.dart';
import '../../widgets/create_character_view/detail_view/sections/proficiency_section.dart';

class CharacterSkillAndEquipmentView extends StatelessWidget {
  const CharacterSkillAndEquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skills & Equipment"),
        backgroundColor: const Color(0xFFE50914),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        buildSkillsSection(vm.skillVM),
        const Divider(height: 40, thickness: 1.5),
        buildProficienciesSection(vm), // ← NUEVO
        const Divider(height: 40, thickness: 1.5),
        buildLanguagesSection(vm.languageVM), // ← NUEVO
        const Divider(height: 40, thickness: 1.5),
        buildEquipmentSection(vm.equipmentVM),
        sectionTitle("Skill Proficiencies"),
        const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }









}