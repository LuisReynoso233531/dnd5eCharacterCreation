import 'package:flutter/material.dart';
import '../../../../view_models/character/character_inventory_view_model.dart';
import '../../../../utils/styled_dropdown.dart';
import '../../../../utils/app_theme.dart';

class ToolSection extends StatelessWidget {
  final CharacterInventoryViewModel inv;
  final TextEditingController controller;

  const ToolSection({super.key, required this.inv, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Herramientas existentes
        ...inv.tools.map(
          (tool) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StyledDropdown<String>(
              value: tool,
              items: inv.tools,
              labelBuilder: (t) => t ?? '',
              onChanged: (_) {},
              icon: Icons.handyman,
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppTheme.primaryRed),
                onPressed: () => inv.removeTool(tool),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ),

        // Agregar herramienta
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: '-- Tools',
                  prefixIcon: const Icon(Icons.handyman, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  inv.addTool(controller.text);
                  controller.clear();
                }
              },
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}