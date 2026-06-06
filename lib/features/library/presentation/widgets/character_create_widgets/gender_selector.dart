import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {

  const GenderSelector({
    super.key,
  });

  @override
  State<GenderSelector>
  createState() =>
      _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {

  String? selectedGender;

  Widget buildGenderRadio(
      String gender,
      ) {

    return Expanded(
      child: Row(
        children: [

          Expanded(
            child: Text(
              gender,

              style:
              const TextStyle(
                fontSize: 20,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),

          Radio<String>(
            value: gender,
            groupValue: selectedGender,
            activeColor: Colors.black,

            onChanged:
                (value) {

              setState(() {

                selectedGender = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        const Text(
          'Gender',

          style:
          TextStyle(
            fontSize: 24,
            fontFamily: 'GrenzeGotisch',
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Row(
          children: [

            buildGenderRadio('Male'),

            buildGenderRadio('Female'),
          ],
        ),
      ],
    );
  }
}