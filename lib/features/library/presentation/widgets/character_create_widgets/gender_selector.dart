import 'package:flutter/material.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  final String selectedGender;
  final ValueChanged<String> onChanged;

  Widget buildGenderRadio(String gender) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Text(
              gender,

              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'JosefinSlab',
                //fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Radio<String>(
            value: gender,
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

        Row(children: [buildGenderRadio('Male'), buildGenderRadio('Female')]),
      ],
    );
  }
}
