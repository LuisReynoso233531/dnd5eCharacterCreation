import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../../view_models/character/character_view_model.dart';
import '../../widgets/create_character_view/race_view/modal_detail_section.dart';
import 'class_selection_view.dart';

class BackgroundSelectionView extends StatefulWidget {
  const BackgroundSelectionView({super.key});

  @override
  State<BackgroundSelectionView> createState() =>
      _BackgroundSelectionViewState();
}

class _BackgroundSelectionViewState extends State<BackgroundSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CreateCharacterViewModel>().fetchBackgrounds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Background')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.backgrounds.length,
              itemBuilder: (context, index) {
                final background = vm.backgrounds[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            background['name']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          'Hold for info',
                          style: TextStyle(
                            fontSize: 10,
                            color: context.dndColors.mutedText,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Skills: ${background['skill_proficiencies'] ?? 'None'}",
                        style: TextStyle(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.dndColors.mutedText,
                    ),
                    onTap: () {
                      vm.setBackground(background);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClassSelectionView(),
                        ),
                      );
                    },
                    onLongPress: () => showBackgroundDetails(
                      context,
                      background,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
