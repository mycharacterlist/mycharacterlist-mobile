import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/presentation/widgets/character_image.dart';

class CharacterMainInformation extends StatelessWidget {
  const CharacterMainInformation({
    super.key,
    required this.character,
  });

  final Character character;

  String _displayValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '—' : trimmed;
  }

  String _genderLabel(String gender) {
    switch (CharacterGender.normalize(gender)) {
      case CharacterGender.female:
        return 'Female';
      case CharacterGender.male:
        return 'Male';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sectionPanel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 220,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                color: Colors.white,
              ),
              child: CharacterImage(
                imagePath: character.mainImagePath,
                width: 220,
                height: 320,
                fit: BoxFit.contain,
                placeholderIconSize: 96,
                showPlaceholderBorder: false,
                enableFullscreenPreview: true,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _InfoRow(label: 'Age: ', value: _displayValue(character.age)),
          const SizedBox(height: 6),
          _InfoRow(label: 'Height: ', value: _displayValue(character.height)),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Archetype: ',
            value: _displayValue(character.archetype),
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Gender: ',
            value: _genderLabel(character.gender),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Japanese name: ',
            value: _displayValue(character.japaneseName),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Anime: ',
            value: _displayValue(character.sourceTitle),
          ),
          if (character.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Description: ',
              value: character.description.trim(),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Italiana',
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Itim',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
