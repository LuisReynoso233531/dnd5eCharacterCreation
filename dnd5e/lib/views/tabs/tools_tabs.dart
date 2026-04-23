import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/tools_view_model.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(title: const Text("Tools")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );
  }
}