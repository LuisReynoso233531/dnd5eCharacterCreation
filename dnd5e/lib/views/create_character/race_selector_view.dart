import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../views/create_character/background_selecter_view.dart';
import '../../utils/app_theme.dart';

class RaceSelectionView extends StatefulWidget {
  const RaceSelectionView({super.key});

  @override
  State<RaceSelectionView> createState() => _RaceSelectionViewState();
}

class _RaceSelectionViewState extends State<RaceSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CreateCharacterViewModel>().fetchRaces(),
    );
  }

  // MODAL DE DETALLES (Se activa con Long Press)
  void _showRaceDetails(BuildContext context, Map<String, dynamic> race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              race['name'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 10),
            _detailSection("Description", race['desc']),
            _detailSection("Ability Score Increase", race['asi_desc']),
            _detailSection("Age", race['age']),
            _detailSection("Size", race['size']),
            _detailSection("Speed", race['speed_desc']),
            _detailSection("Languages", race['languages']),
            if (race['vision'] != null)
              _detailSection("Vision", race['vision']),
            _detailSection("Traits", race['traits']),
          ],
        ),
      ),
    );
  }

  Widget _detailSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty)
      return const SizedBox.shrink();
    String cleanContent = content.toString().replaceAll(RegExp(r'[\*#_]'), '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(cleanContent, style: const TextStyle(fontSize: 14, height: 1.4)),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Race"),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (vm.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            ),

          if (!vm.isLoading && vm.races.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.races.length,

                // ... dentro del ListView.builder en RaceSelectionView
                itemBuilder: (context, index) {
                  final race = vm.races[index];
                  final List<dynamic> asiList = race['asi'] ?? [];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        race['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryRed,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Speed: ${race['speed']['walk']} ft.",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // --- EL TEXTO DE AYUDA ---
                          const Text(
                            "Hold for info",
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        children: asiList.map((asi) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${asi['attributes'][0]} +${asi['value']}",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Toque normal: SELECCIONA Y AVANZA
                      onTap: () {
                        vm.setRace(race);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BackgroundSelectionView(),
                          ),
                        );
                      },

                      // Toque largo: MUESTRA DETALLES
                      onLongPress: () => _showRaceDetails(context, race),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
