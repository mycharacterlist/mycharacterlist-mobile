import 'package:flutter/material.dart';

class CharacterPersonalNotes extends StatelessWidget {

  const CharacterPersonalNotes({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration:
      const BoxDecoration(
        color: Color(0xFFECEBEB),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            'Personal notes:',

            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),

          SizedBox(height: 10),

          Text(
            'This character is one of the most popular tsundere heroines in anime. She comes from a noble family and studies at Tristain Academy of Magic.',

            style: TextStyle(
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