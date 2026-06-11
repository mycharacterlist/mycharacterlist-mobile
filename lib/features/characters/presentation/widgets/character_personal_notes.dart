import 'package:flutter/material.dart';

class CharacterPersonalNotes extends StatelessWidget {
  const CharacterPersonalNotes({
    super.key,
    required this.notes,
  });

  final String notes;

  @override
  Widget build(BuildContext context) {
    final trimmedNotes = notes.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFECEBEB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal notes:',
            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            trimmedNotes.isEmpty ? 'No notes' : trimmedNotes,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),
        ],
      ),
    );
  }
}
