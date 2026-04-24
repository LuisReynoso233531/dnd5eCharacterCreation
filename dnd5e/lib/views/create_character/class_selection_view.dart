import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';
import '../../data/models/character_class.dart';

class ClassSelectionView extends StatefulWidget {
  const ClassSelectionView({super.key});

  @override
  State<ClassSelectionView> createState() => _ClassSelectionViewState();
}

class _ClassSelectionViewState extends State<ClassSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CreateCharacterViewModel>().fetchAvailableClasses(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your class"),
        backgroundColor: const Color(0xFFE50914),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banner de resumen de Raza
          if (vm.selectedRace != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Row(
                children: [
                  const Icon(Icons.person, color: Color(0xFFE50914), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Race: ${vm.selectedRace!['name']} | Speed: ${vm.speed} ft. | ${vm.racialBonuses.entries.map((e) => "${e.key} +${e.value}").join(', ')}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Lista de Clases
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: vm.classes.length,
                    itemBuilder: (context, index) {
                      final charClass = vm.classes[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            vm.selectClass(charClass);
                            // Navegar a la pantalla de Stats (Siguiente paso)
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icono o Sangre (como en tu imagen)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.water_drop, color: Colors.red, size: 24),
                                ),
                                const SizedBox(width: 16),
                                
                                // Información de la Clase
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        charClass.name,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      // Usamos Wrap en lugar de Row para que si el texto es muy largo, baje a la siguiente línea
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          _buildClassInfo(Icons.favorite, "Hit Die: 1d${charClass.hit_dice}", Colors.red),
                                          _buildClassInfo(Icons.auto_fix_high, "Saves: ${charClass.prof_saving_throws}", Colors.blue),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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

  // Widget auxiliar para los iconos y texto debajo del nombre
  Widget _buildClassInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
        ),
      ],
    );
  }
}