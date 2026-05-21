import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../widgets/create_character_view/detail_view/sections/skills_section.dart';
import '../../widgets/create_character_view/detail_view/sections/equipment_section.dart';
import '../../widgets/create_character_view/detail_view/sections/language_section.dart';
import '../../widgets/create_character_view/detail_view/sections/proficiency_section.dart';
import '../../view_models/character/character_skill_view_model.dart';
import '../../view_models/character/character_equipment_view_model.dart';
import '../../view_models/character/character_language_view_model.dart';
import '../../view_models/character/character_detail_class_view_model.dart';
import '../../view_models/character/character_subclass_view_model.dart';
import '../../views/create_character/detail_class_view.dart';
import '../../widgets/create_character_view/detail_view/sections/dragonbron_section.dart';
import '../../utils/app_theme.dart';

class CharacterSkillAndEquipmentView extends StatelessWidget {
  const CharacterSkillAndEquipmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();
    // ← Escuchar los sub-VMs directamente para que sus cambios
    //   también disparen un rebuild de esta View
    context.watch<CharacterEquipmentViewModel>();
    context.watch<CharacterSkillViewModel>();
    context.watch<CharacterLanguageViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Skills & Equipment"),
        backgroundColor: AppTheme.primaryRed,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSkillsSection(vm.skillVM),
            const Divider(height: 40, thickness: 1.5),
            buildProficienciesSection(vm),
            const Divider(height: 40, thickness: 1.5),
            buildLanguagesSection(vm.languageVM),
            const Divider(height: 40, thickness: 1.5),
            buildEquipmentSection(vm.equipmentVM),
            const Divider(height: 40, thickness: 1.5),
            buildDragonbornAncestrySection(vm),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider<DetailClassViewModel>(
                            create: (_) => DetailClassViewModel(),
                          ),
                          ChangeNotifierProxyProvider2<
                            DetailClassViewModel,
                            CreateCharacterViewModel,
                            CharacterSubclassViewModel
                          >(
                            create: (ctx) => CharacterSubclassViewModel(),
                            update: (ctx, detailClassVM, createCharVM, subclassVM) {
                              return subclassVM!..updateDependencies(
                                detailClassVM: detailClassVM,
                                skillVM: createCharVM.skillVM,
                              );
                            },
                          ),
                        ],
                        child: const DetailClassView(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text(
                  'Continue to Class Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
