import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
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
            child: CharacterImage(
              imagePath: character.mainImagePath,
              characterFolder: character.id,
              width: 220,
              height: 320,
              placeholderIconSize: 96,
              showPlaceholderBorder: true,
              enableFullscreenPreview: true,
            ),
          ),
          const SizedBox(height: 15),
          _InfoRow(
            label: 'Age: ',
            value: _displayValue(character.age),
            copyLabel: 'age',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Height: ',
            value: _displayValue(character.height),
            copyLabel: 'height',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Archetype: ',
            value: _displayValue(character.archetype),
            copyLabel: 'archetype',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Gender: ',
            value: _genderLabel(character.gender),
            copyLabel: 'gender',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Japanese name: ',
            value: _displayValue(character.japaneseName),
            copyLabel: 'Japanese name',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Anime: ',
            value: _displayValue(character.sourceTitle),
            copyLabel: 'anime',
          ),
          if (character.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Description: ',
              value: character.description.trim(),
              copyLabel: 'description',
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
    required this.copyLabel,
  });

  final String label;
  final String value;
  final String copyLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _copyValue(context),
      child: RichText(
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
      ),
    );
  }

  Future<void> _copyValue(BuildContext context) async {
    final text = value.trim();
    if (text.isEmpty || text == '—') {
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      AppSnackBar.showCentered(context, 'Copied $copyLabel');
    }
  }
}
