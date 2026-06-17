import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

class CharacterPersonalNotes extends StatelessWidget {
  const CharacterPersonalNotes({
    super.key,
    required this.notes,
  });

  final String notes;

  @override
  Widget build(BuildContext context) {
    final trimmedNotes = notes.trim();

    return CharacterSectionPanel(
      title: 'Personal notes:',
      child: Text(
        trimmedNotes.isEmpty ? 'No notes' : trimmedNotes,
        style: AppTypography.characterSectionEmpty,
      ),
    );
  }
}
