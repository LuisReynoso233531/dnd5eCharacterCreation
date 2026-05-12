
  import 'package:flutter/material.dart';
  
  // FUNCIÓN PARA MOSTRAR EL MODAL DE INFORMACIÓN
  void showBackgroundDetails(BuildContext context, Map<String, dynamic> bg) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(bg['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                  const Divider(),
                  
                  _buildModalSection("Description", bg['desc']),
                  _buildModalSection("Skill Proficiencies", bg['skill_proficiencies']),
                  _buildModalSection("Tool Proficiencies", bg['tool_proficiencies']),
                  _buildModalSection("Languages", bg['languages']),
                  _buildModalSection("Equipment", bg['equipment']),
                  _buildModalSection("Feature: ${bg['feature'] ?? ''}", bg['feature_desc']),
                  
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalSection(String title, dynamic content) {
    if (content == null || content.toString().isEmpty || content == "null") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(content.toString(), style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4)),
        ],
      ),
    );
  }