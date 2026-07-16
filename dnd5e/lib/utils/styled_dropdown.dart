import 'package:flutter/material.dart';

import 'app_theme.dart';

class StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T?> items;
  final String Function(T?) labelBuilder;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final Widget? trailing;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.dndColors.surfaceRaised,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.dndColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.dndColors.mutedText),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: context.dndColors.surfaceRaised,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          labelBuilder(item),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
