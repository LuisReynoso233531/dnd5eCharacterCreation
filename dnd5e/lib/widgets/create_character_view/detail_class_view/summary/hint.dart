import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';

Widget hint(String text) {
  return Builder(
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(color: context.dndColors.mutedText, fontSize: 13),
      ),
    ),
  );
}
