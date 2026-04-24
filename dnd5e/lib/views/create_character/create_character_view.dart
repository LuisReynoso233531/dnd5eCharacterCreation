import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/character/character_view_model.dart';

class CreateCharacterView extends StatefulWidget {
  const CreateCharacterView({super.key});

  @override
  State<CreateCharacterView> createState() => _CreateCharacterViewState();
}

class _CreateCharacterViewState extends State<CreateCharacterView> {
  @override
  void initState() {
    super.initState();
    // Pedimos las clases al iniciar la pantalla
    Future.microtask(() =>
        context.read<CreateCharacterViewModel>().fetchAvailableClasses());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Crear Personaje")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.classes.length,
              itemBuilder: (context, index) {
                final charClass = vm.classes[index];
                return ListTile(
                  title: Text(charClass.name),
                  subtitle: Text("Dado de vida: d${charClass.hit_dice}"),
                  selected: vm.selectedClass == charClass,
                  onTap: () => vm.selectClass(charClass),
                );
              },
            ),
    );
  }
}