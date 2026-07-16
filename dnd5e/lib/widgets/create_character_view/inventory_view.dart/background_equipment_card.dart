import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';

class BackgroundEquipmentCard extends StatelessWidget {
  final String text;

  const BackgroundEquipmentCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dndColors.infoContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.dndColors.info.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history_edu, color: context.dndColors.info, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.dndColors.onInfoContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
