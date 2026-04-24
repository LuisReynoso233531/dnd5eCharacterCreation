import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';

class RaceSelectionView extends StatefulWidget {
  const RaceSelectionView({super.key});

  @override
  State<RaceSelectionView> createState() => _RaceSelectionViewState();
}

class _RaceSelectionViewState extends State<RaceSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CreateCharacterViewModel>().fetchRaces());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Race"),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (vm.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          
          if (vm.errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(vm.errorMessage!, textAlign: TextAlign.center),
                    ElevatedButton(
                      onPressed: () => vm.fetchRaces(),
                      child: const Text("Reintentar"),
                    )
                  ],
                ),
              ),
            ),

          if (!vm.isLoading && vm.races.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: vm.races.length,
                itemBuilder: (context, index) {
                  final race = vm.races[index];
                  final List<dynamic> asiList = race['asi'] ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        vm.setRace(race);
                        // Aquí iría el Navigator a la siguiente pantalla de Clase
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // LADO IZQUIERDO: Nombre y Descripción
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    race['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE50914), // Tu rojo característico
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Speed: ${race['speed']['walk']} ft.",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            
                            // LADO DERECHO: Modificadores (ASI)
                            Expanded(
                              flex: 2,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 4,
                                runSpacing: 4,
                                children: asiList.map((item) {
                                  final attribute = item['attributes'][0];
                                  final value = item['value'];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      "$attribute +$value",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
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