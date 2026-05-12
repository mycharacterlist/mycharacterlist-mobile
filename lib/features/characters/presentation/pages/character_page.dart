import 'package:flutter/material.dart';

class CharacterPage extends StatelessWidget {
  const CharacterPage({super.key, required this.characterId});

  final String characterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Character page')),
      body: const Center(child: Text('Character page')),
    );
  }
}
