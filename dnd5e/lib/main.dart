import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa tus carpetas (asegúrate de que las rutas sean correctas)
import 'utils/app_theme.dart'; 
import 'data/repositories/character_repository.dart';
import 'view_models/theme_view_model.dart';
import 'view_models/character/character_view_model.dart';
import 'view_models/spell/spells_view_model.dart';
import 'view_models/bestiary/bestiary_view_model.dart';
import 'view_models/tools/tools_view_model.dart';
import 'views/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './view_models/character/character_skill_view_model.dart';
import './view_models/character/character_equipment_view_model.dart';
import './view_models/character/character_language_view_model.dart';
void main() async{
  await dotenv.load(fileName: ".env");
  runApp(
   MultiProvider(
      providers: [
        // 1. EL REPOSITORIO DEBE IR PRIMERO
        Provider(create: (_) => CharacterRepository()),

        // 2. EL TEMA
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),

        // 3. LOS VIEWMODELS HIJOS (Independientes)
        ChangeNotifierProvider(create: (_) => CharacterSkillViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterEquipmentViewModel()),
        ChangeNotifierProvider(create: (_) => CharacterLanguageViewModel()),

        // 4. EL VIEWMODEL PRINCIPAL (Depende de los 3 anteriores)
        // NOTA: Aquí agregamos el < ... > que faltaba
        ChangeNotifierProxyProvider3<
            CharacterSkillViewModel,
            CharacterEquipmentViewModel,
            CharacterLanguageViewModel,
            CreateCharacterViewModel>(
          create: (ctx) => CreateCharacterViewModel(
            ctx.read<CharacterRepository>(),
            skillViewModel: ctx.read<CharacterSkillViewModel>(),
            equipmentViewModel: ctx.read<CharacterEquipmentViewModel>(),
            languageViewModel: ctx.read<CharacterLanguageViewModel>(),
          ),
          // El método update se asegura de que si los sub-viewmodels cambian, el principal se entere
          update: (ctx, skillVM, equipVM, langVM, prev) {
            // Aquí puedes sincronizar si es necesario, 
            // pero si ya los pasaste por constructor, solo devolvemos el previo.
            return prev!;
          },
        ),
        
        // Otros ViewModels
        ChangeNotifierProvider(create: (_) => SpellsViewModel()),
        ChangeNotifierProvider(create: (_) => BestiaryViewModel()),
        ChangeNotifierProvider(create: (_) => ToolsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el cambio de tema para que la app reaccione
    final themeVM = context.watch<ThemeViewModel>();
  
    return MaterialApp(
      title: '5e Character Design',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: themeVM.themeMode, 

      home: const MainScreen(),
    );
  }
}