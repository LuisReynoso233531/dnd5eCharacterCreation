import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_theme.dart';
import '../view_models/theme_view_model.dart';
import 'tabs/bestiary_tabs.dart';
import 'tabs/character_tabs.dart';
import 'tabs/spells_tabs.dart';
import 'tabs/tools_tabs.dart';

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
    final isDarkMode = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('5e Character Design'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open settings',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeVM.setDarkMode(!isDarkMode),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.78),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.settings, color: Colors.white, size: 30),
                    SizedBox(height: 14),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark mode'),
                subtitle: Text(
                  isDarkMode ? 'Enabled' : 'Disabled',
                  style: TextStyle(color: context.dndColors.mutedText),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: themeVM.setDarkMode,
                ),
                onTap: () => themeVM.setDarkMode(!isDarkMode),
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App info'),
                subtitle: Text(
                  'Legal notice, licenses, and acknowledgements',
                  style: TextStyle(color: context.dndColors.mutedText),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: context.dndColors.subtleText,
                ),
                onTap: () => _showAppInfo(context),
              ),
            ],
          ),
        ),
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => _pageController.jumpToPage(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_fix_high_outlined),
            activeIcon: Icon(Icons.auto_fix_high),
            label: 'Spells',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Bestiary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.casino_outlined),
            activeIcon: Icon(Icons.casino),
            label: 'Tools',
          ),
        ],
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return FractionallySizedBox(
          heightFactor: 0.90,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'App Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _appLegalNotice,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const String _appLegalNotice = '''
LEGAL NOTICE AND THIRD-PARTY ATTRIBUTIONS

UNOFFICIAL APPLICATION

This application is an independently developed and unofficial character-creation, character-management, and reference tool for fifth-edition-compatible tabletop role-playing games.

This application is not affiliated with, sponsored by, endorsed by, approved by, or published by Wizards of the Coast LLC, Hasbro, D&D Beyond, Open5e, or any third-party publisher whose materials may be referenced or displayed.

INTELLECTUAL PROPERTY

All trademarks, service marks, product names, game titles, logos, characters, campaign settings, artwork, rules text, and other intellectual property belong to their respective owners.

No ownership of third-party intellectual property is claimed by the developers of this application. All rights not expressly granted under an applicable license are reserved by the relevant rights holder.

SYSTEM REFERENCE DOCUMENT

This work includes material taken from the System Reference Document 5.1 (“SRD 5.1”) by Wizards of the Coast LLC.

Official source:
https://www.dndbeyond.com/srd

License:
Creative Commons Attribution 4.0 International
https://creativecommons.org/licenses/by/4.0/legalcode

The SRD material is used under the terms of that license. Use of SRD material does not indicate sponsorship, approval, or endorsement of this application by Wizards of the Coast.

OPEN5E AND THIRD-PARTY MATERIAL

Certain game information used by this application may be obtained through the Open5e API or related Open5e data sources.

Open5e contains material from multiple publishers and under multiple open licenses. Each source remains subject to its own copyright notice, attribution requirements, product identity declarations, and license terms.

The copyright and other intellectual-property rights in those materials remain with their respective authors and publishers. Inclusion of third-party material does not imply that any author, publisher, or data provider sponsors or endorses this application.

The applicable source, publisher, and license information should be consulted for each item of third-party content.

APPLICATION CONTENT

The original source code, interface design, organization, and application-specific functionality are owned by their respective developers, except for third-party libraries and materials used under their corresponding licenses.

This application may include open-source software packages. Those packages remain governed by their own copyright notices and license terms.

USER-GENERATED CONTENT

Character names, campaign information, notes, custom descriptions, and other information entered by users are the responsibility of those users.

Users must not use this application to reproduce, distribute, publish, or otherwise exploit copyrighted material unless they have permission or a valid license to do so.

REFERENCE PURPOSE

This application is provided as an organizational and reference tool. It is not a replacement for official rulebooks, licensed publications, or rulings made by a Game Master.

The application may contain errors, omissions, unofficial interpretations, homebrew material, or information originating from different fifth-edition-compatible game systems.

NO WARRANTY

To the maximum extent permitted by applicable law, this application and its contents are provided “as is” and “as available,” without warranties of any kind, either express or implied.

The developers make no guarantee regarding the completeness, accuracy, legality, availability, or fitness for a particular purpose of any information displayed by the application.

Users are responsible for verifying the rules, licenses, and permissions applicable to their own use of the application and its contents.

All rights not expressly granted are reserved by their respective owners.
''';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
