import 'package:flutter/material.dart';

class CharacterMainInformation extends StatelessWidget {

  const CharacterMainInformation({
    super.key,

    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.only(
        left: 5,
        top: 8,
        right: 12,
        bottom: 12,
      ),

      decoration:
      const BoxDecoration(
        color: Color(0xFFECEBEB),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Center(
            child: SizedBox(
              width: 220,
              height: 320,

              child: ClipRRect(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Age: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text: '16',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Height: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text: '153',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Archetype: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text: 'Tsundere',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Gender: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text: 'Female',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Japanese name: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text:
                  'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          RichText(
            text: const TextSpan(
              children: [

                TextSpan(
                  text: 'Anime: ',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Italiana',
                  ),
                ),

                TextSpan(
                  text: 'The Familiar of Zero',

                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontFamily: 'Itim',
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