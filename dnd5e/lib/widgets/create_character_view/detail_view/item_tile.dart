import 'package:flutter/material.dart';

Widget itemTile(String text, IconData icon, Color color) => ListTile(
  leading: Icon(icon, color: color),
  title: Text(text, style: const TextStyle(fontSize: 14)),
  dense: true,
  contentPadding: EdgeInsets.zero,
);
