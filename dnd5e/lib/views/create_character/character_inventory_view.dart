import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_models/character/character_view_model.dart';
import '../../view_models/character/character_inventory_view_model.dart';
import '../../widgets/create_character_view/inventory_view.dart/character_inventory_content.dart';

class CharacterInventoryView extends StatefulWidget {
  const CharacterInventoryView({super.key});

  @override
  State<CharacterInventoryView> createState() => _CharacterInventoryViewState();
}

class _CharacterInventoryViewState extends State<CharacterInventoryView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterInventoryViewModel>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final characterVM = context.watch<CreateCharacterViewModel>();
    final inventoryVM = context.watch<CharacterInventoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment'),
      ),
      body: inventoryVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CharacterInventoryContent(
              characterVM: characterVM,
              inventoryVM: inventoryVM,
            ),
    );
  }
}
