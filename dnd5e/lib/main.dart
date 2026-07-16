import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'data/repositories/character_repository.dart';
import 'utils/app_theme.dart';
import 'view_models/bestiary/bestiary_view_model.dart';
import 'view_models/character/character_equipment_view_model.dart';
import 'view_models/character/character_language_view_model.dart';
import 'view_models/character/character_skill_view_model.dart';
import 'view_models/character/character_view_model.dart';
import 'view_models/spell/spells_view_model.dart';
import 'view_models/theme_view_model.dart';
import 'view_models/tools/hp_tracker_view_model.dart';
import 'views/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => CharacterRepository()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterSkillViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterEquipmentViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterLanguageViewModel()),
        ChangeNotifierProxyProvider3<
            CharacterSkillViewModel,
            CharacterEquipmentViewModel,
            CharacterLanguageViewModel,
            CreateCharacterViewModel>(
          create: (context) => CreateCharacterViewModel(
            context.read<CharacterRepository>(),
            skillViewModel: context.read<CharacterSkillViewModel>(),
            equipmentViewModel: context.read<CharacterEquipmentViewModel>(),
            languageViewModel: context.read<CharacterLanguageViewModel>(),
          ),
          update: (context, skillVM, equipmentVM, languageVM, previous) =>
              previous!,
        ),
        ChangeNotifierProvider(create: (_) => SpellsViewModel()),
        ChangeNotifierProvider(create: (_) => BestiaryViewModel()),
        ChangeNotifierProvider(create: (_) => HpTrackerViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();

    return MaterialApp(
      title: '5e Character Design',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeViewModel.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 260),
      themeAnimationCurve: Curves.easeOutCubic,
      home: const MainScreen(),
    );
  }
}
