import 'package:flutter/material.dart';

class CharacterRanksStanding extends StatelessWidget {

  const CharacterRanksStanding({
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const Text(
            'Ranks standing (positions):',

            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),

          const SizedBox(height: 10),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: '▪ Main rank: ',

                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'JockeyOne',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextSpan(
                  text: '#1',

                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'JimNightshade',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: '▪ Potential rank: ',

                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'JockeyOne',
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextSpan(
                  text: '#23',

                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontFamily: 'JimNightshade',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}