import 'package:flutter/material.dart';

class CharacterPersonalGrades extends StatelessWidget {

  const CharacterPersonalGrades({
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
            'Personal grades:',

            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),

          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: const [

              _GradeRow(
                title: 'Appearance',
                grade: '10/10',
              ),

              SizedBox(height: 10),

              _GradeRow(
                title: 'Character',
                grade: '10/10',
              ),

              SizedBox(height: 10),

              _GradeRow(
                title: 'Haircut',
                grade: '10/10',
              ),

              SizedBox(height: 10),

              _GradeRow(
                title: 'Eyes',
                grade: '10/10',
              ),

              SizedBox(height: 10),

              _GradeRow(
                title: 'Outfit',
                grade: '10/10',
              ),

              SizedBox(height: 10),

              _GradeRow(
                title: 'Overall',
                grade: '10/10',
                underline: true,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {

  final String title;

  final String grade;

  final bool underline;

  const _GradeRow({
    required this.title,
    required this.grade,
    this.underline = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return RichText(
      text: TextSpan(
        children: [

          TextSpan(
            text: '$title: ',

            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,

              decoration:
              underline
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),

          TextSpan(
            text: grade,

            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JimNightshade',
            ),
          ),
        ],
      ),
    );
  }
}