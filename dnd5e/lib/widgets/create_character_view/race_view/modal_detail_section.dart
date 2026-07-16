import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';

void showBackgroundDetails(BuildContext context, Map<String, dynamic> bg) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
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
                    decoration: BoxDecoration(
                      color: context.dndColors.borderStrong,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  bg['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const Divider(),
                _buildModalSection(context, 'Description', bg['desc']),
                _buildModalSection(
                  context,
                  'Skill Proficiencies',
                  bg['skill_proficiencies'],
                ),
                _buildModalSection(
                  context,
                  'Tool Proficiencies',
                  bg['tool_proficiencies'],
                ),
                _buildModalSection(context, 'Languages', bg['languages']),
                _buildModalSection(context, 'Equipment', bg['equipment']),
                _buildModalSection(
                  context,
                  "Feature: ${bg['feature'] ?? ''}",
                  bg['feature_desc'],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildModalSection(
  BuildContext context,
  String title,
  dynamic content,
) {
  if (content == null || content.toString().isEmpty || content == 'null') {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          content.toString(),
          style: TextStyle(
            fontSize: 14,
            color: context.dndColors.mutedText,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}
