import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import 'class_selection_view.dart';
import '../../widgets/create_character_view/race_view/modal_detail_section.dart';
import '../../utils/app_theme.dart';

class BackgroundSelectionView extends StatefulWidget {
  const BackgroundSelectionView({super.key});

  @override
  State<BackgroundSelectionView> createState() => _BackgroundSelectionViewState();
}

class _BackgroundSelectionViewState extends State<BackgroundSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CreateCharacterViewModel>().fetchBackgrounds());
  }


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Choose Background"), backgroundColor: AppTheme.primaryRed),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.backgrounds.length,
              itemBuilder: (context, index) {
                final bg = vm.backgrounds[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(bg['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text("Hold for info", style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Skills: ${bg['skill_proficiencies'] ?? 'None'}", 
                             style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    onTap: () {
                      vm.setBackground(bg);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ClassSelectionView()));
                    },
                    onLongPress: () => showBackgroundDetails(context, bg),
                  ),
                );
              },
            ),
    );
  }
}