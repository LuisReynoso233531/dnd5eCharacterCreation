import 'package:flutter/material.dart';

class BackgroundEquipmentCard extends StatelessWidget {
  final String text;
  const BackgroundEquipmentCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.history_edu, color: Colors.blueGrey.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blueGrey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}