import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../views/create_character/background_selecter_view.dart';
import 'class_selection_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Race"),
        backgroundColor: const Color(0xFFE50914),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (vm.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              ),
            ),

          if (vm.errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(vm.errorMessage!, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => vm.fetchRaces(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            ),

          if (!vm.isLoading && vm.races.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.races.length,
                itemBuilder: (context, index) {
                  final race = vm.races[index];
                  final List<dynamic> asiList = race['asi'] ?? [];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        race['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE50914),
                        ),
                      ),
                      subtitle: Text(
                        "Speed: ${race['speed']['walk']} ft.",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        children: asiList.map((asi) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
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
                      onTap: () {
                        vm.setRace(race);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BackgroundSelectionView(),
                          ), // Ahora va a Backgrounds
                        );
                      },
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
