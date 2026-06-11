import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  final String selectedGender;
  final ValueChanged<String> onChanged;

  Widget buildGenderRadio(String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,

              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'JosefinSlab',
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Radio<String>(
            value: value,
            groupValue: selectedGender,
            activeColor: Colors.black,

            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Gender',

          style: TextStyle(
            fontSize: 24,
            fontFamily: 'GrenzeGotisch',
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            buildGenderRadio(CharacterGender.male, 'Male'),
            buildGenderRadio(CharacterGender.female, 'Female'),
          ],
        ),
      ],
    );
  }
}
