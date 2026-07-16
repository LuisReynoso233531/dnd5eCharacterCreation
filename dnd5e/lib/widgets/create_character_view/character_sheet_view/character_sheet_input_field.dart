import 'package:flutter/material.dart';

import '../../../utils/app_theme.dart';

class CharacterSheetInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const CharacterSheetInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.hint,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: context.dndColors.surfaceRaised,
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13),
    );
  }
}
