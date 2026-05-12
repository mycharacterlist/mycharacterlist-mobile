import 'package:flutter/material.dart';

class CharacterCreatePage extends StatelessWidget {
  const CharacterCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create character')),
      body: const Center(child: Text('Character create page')),
    );
  }
}
