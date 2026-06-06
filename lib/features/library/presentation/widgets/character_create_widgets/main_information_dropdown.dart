import 'package:flutter/material.dart';
import 'gender_selector.dart';
import 'fields/archetype_field.dart';
import 'fields/anime_field.dart';

class MainInformationDropdown extends StatefulWidget {

  const MainInformationDropdown({
    super.key,
  });

  @override
  State<MainInformationDropdown>
  createState() =>
      _MainInformationDropdownState();
}

class _MainInformationDropdownState extends State<MainInformationDropdown> {

  bool isExpanded = false;

  final TextEditingController
  nameController = TextEditingController();

  final TextEditingController
  ageController = TextEditingController();

  final TextEditingController
  heightController = TextEditingController();

  final TextEditingController
  japaneseNameController = TextEditingController();

  final List<String>
  animeList = [
    'Code Geass',
    'Naruto',
    'Bleach',
    'Attack on Titan',
    'Classroom of the Elite',
    'Death Note',
  ];

  final List<String>
  archetypes = [
    'Dandere',
    'Deredere',
    'Himedere',
    'Kuudere',
    'Tsundere',
    'Yandere',
  ];

  Widget buildField(
      String label,
      TextEditingController controller,
      ) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        decoration:
        InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.65),

          border:
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                      'Main information',

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
                  const GenderSelector(),

                  const SizedBox(height: 12),

                  buildField(
                    'Name (Name, Surname)',
                    nameController,
                  ),

                  buildField(
                    'Age',
                    ageController,
                  ),

                  buildField(
                    'Height (cm)',
                    heightController,
                  ),

                  buildField(
                    'Japanese name',
                    japaneseNameController,
                  ),

                  const SizedBox(height: 12),

                  const AnimeField(),

                  const SizedBox(height: 12),

                  const ArchetypeField(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}