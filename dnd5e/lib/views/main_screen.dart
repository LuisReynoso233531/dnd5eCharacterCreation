import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/theme_view_model.dart';
import './tabs/bestiary_tabs.dart';
import './tabs/character_tabs.dart';
import './tabs/tools_tabs.dart';
import './tabs/spells_tabs.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return Scaffold(
      // 1. EL HEADER (AppBar)
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "5e Character Design",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        // Ícono de la Sidebar (Hamburgesa)
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // 2. EL SIDEBAR (Drawer)
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFE50914)),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(themeVM.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(themeVM.isDarkMode ? "Dark Mode" : "Light Mode"),
              trailing: Switch(
                value: themeVM.isDarkMode,
                onChanged: (_) => themeVM.toggleTheme(),
              ),
              onTap: () => themeVM.toggleTheme(),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("App Info"),
            ),
          ],
        ),
      ),

      // 3. CUERPO (Tabs con PageView para mantener el estado)
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          CharacterTab(),
          SpellsTab(),
          BestiaryTab(),
          ToolsTab(),
        ],
      ),

      // 4. NAVEGACIÓN INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _pageController.jumpToPage(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE50914),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Characters"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_fix_high), label: "Spells"),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), label: "Bestiary"),
          BottomNavigationBarItem(icon: Icon(Icons.casino_outlined), label: "Tools"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}