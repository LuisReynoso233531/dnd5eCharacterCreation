import 'package:flutter/material.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: Text("Campaign Notes Coming Soon...")),
    );
  }
}