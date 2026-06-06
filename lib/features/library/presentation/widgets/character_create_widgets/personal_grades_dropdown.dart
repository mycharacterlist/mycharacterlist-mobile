import 'package:flutter/material.dart';

class PersonalGradesDropdown extends StatefulWidget {

  const PersonalGradesDropdown({
    super.key,
  });

  @override
  State<PersonalGradesDropdown>
  createState() =>
      _PersonalGradesDropdownState();
}

class _PersonalGradesDropdownState extends State<PersonalGradesDropdown> {

  bool isExpanded = false;

  final TextEditingController
  appearanceController = TextEditingController();

  final TextEditingController
  characterController = TextEditingController();

  final TextEditingController
  outfitController = TextEditingController();

  final TextEditingController
  haircutController = TextEditingController();

  final TextEditingController
  eyesController = TextEditingController();

  Widget buildGradeField(
      String title,
      TextEditingController controller,
      ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Row(
        children: [

          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                fontSize: 25,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),

          SizedBox(
            width: 45,
            height: 35,

            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,

              decoration:
              InputDecoration(
                contentPadding:
                EdgeInsets.zero,

                filled: true,

                fillColor: Colors.white.withOpacity(0.65),

                border:
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(width: 5),

          const Text(
            '/10',

            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      decoration:
      BoxDecoration(
        color: Colors.transparent,

        border:
        Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),

      child: Column(
        children: [

          InkWell(
            onTap: () {

              setState(() {

                isExpanded = !isExpanded;
              });
            },

            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              child: Row(
                children: [

                  const Expanded(
                    child: Text(
                      'Personal grades',

                      style:
                      TextStyle(
                        fontSize: 28,
                        fontFamily: 'GrenzeGotisch',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,

                    size: 35,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)

            Padding(
              padding:
              const EdgeInsets.all(12),

              child: Column(
                children: [

                  buildGradeField(
                    'Appearance',
                    appearanceController,
                  ),

                  const SizedBox(height: 12),

                  buildGradeField(
                    'Character',
                    characterController,
                  ),

                  const SizedBox(height: 12),

                  buildGradeField(
                    'Outfit',
                    outfitController,
                  ),

                  const SizedBox(height: 12),

                  buildGradeField(
                    'Haircut',
                    haircutController,
                  ),

                  const SizedBox(height: 12),

                  buildGradeField(
                    'Eyes',
                    eyesController,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}