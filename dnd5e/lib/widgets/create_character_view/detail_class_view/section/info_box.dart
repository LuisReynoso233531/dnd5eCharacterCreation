  import 'package:flutter/material.dart';

  
  Widget infoBox({
    required IconData icon,
    required MaterialColor color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade300),
      ),
      child: Row(children: [
        Icon(icon, color: color.shade800, size: 18),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color.shade900,
                    fontSize: 13,
                    fontWeight: FontWeight.w500))),
      ]),
    );
  }