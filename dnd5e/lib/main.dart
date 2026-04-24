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
void main() async{
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        // 1. Repositorio (Base de datos/API)
        Provider(create: (_) => CharacterRepository()),

        // 2. ViewModel del Tema (Modo Oscuro)
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),

        // 3. ViewModels de las pantallas
        ChangeNotifierProvider(
          create: (context) => CreateCharacterViewModel(context.read<CharacterRepository>()),
        ),
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