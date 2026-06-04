import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.only(bottom: 12,),

      child: TextField(
        controller: controller,

        decoration:
        InputDecoration(
          labelText: label,

          filled: true,

          fillColor: Colors.white.withOpacity(0.65,),

          border:
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(12,),
          ),
        ),
      ),
    );
  }

  Widget buildAnimeField() {

    return Autocomplete<String>(
      optionsBuilder:
          (
          TextEditingValue
          textEditingValue,
          ) {

        if (textEditingValue.text.isEmpty)
        {

          return const Iterable<
              String>.empty();
        }

        return animeList.where(
              (item) {

            return item
                .toLowerCase()
                .startsWith(
              textEditingValue
                  .text
                  .toLowerCase(),
            );
          },
        );
      },

      fieldViewBuilder:
          (
          context,
          controller,
          focusNode,
          onFieldSubmitted,
          ) {

        return TextField(
          controller: controller,

          focusNode: focusNode,

          decoration:
          InputDecoration(
            labelText: 'Anime',
            filled: true,
            fillColor: Colors.white.withOpacity(0.65,),

            border:
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12,),
            ),

            suffixIcon:
            Padding(
              padding: const EdgeInsets.all(4,),

              child:
              ElevatedButton(
                onPressed: () {},

                style:
                ElevatedButton.styleFrom(
                  elevation: 0,

                  backgroundColor: Colors.transparent,

                  foregroundColor: const Color(0xFF7B61FF,),

                  side:
                  const BorderSide(
                    color: Color(0xFF7B61FF,),
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10,),
                  ),
                ),

                child:
                const Text('New+',),
              ),
            ),

            suffixIconConstraints:
            const BoxConstraints(
              minWidth: 90,
              minHeight: 40,
            ),
          ),
        );
      },

      optionsViewBuilder:
          (
          context,
          onSelected,
          options,
          ) {

        return Material(
          elevation: 4,

          child: Container(
            constraints:
            const BoxConstraints(maxHeight: 200,),

            color: Colors.white,

            child: ListView.builder(
              shrinkWrap: true,

              itemCount: options.length,

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                final option = options.elementAt(index,);

                return ListTile(
                  title: Text(option,),

                  onTap: () {

                    onSelected(option,);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildArchetypeField() {

    return Autocomplete<String>(
      optionsBuilder:
          (
          TextEditingValue
          textEditingValue,
          ) {

        if (textEditingValue.text.isEmpty)
        {

          return const Iterable<
              String>.empty();
        }

        return archetypes.where(
              (item) {

            return item
                .toLowerCase()
                .contains(
              textEditingValue
                  .text
                  .toLowerCase(),
            );
          },
        );
      },

      fieldViewBuilder:
          (
          context,
          controller,
          focusNode,
          onFieldSubmitted,
          ) {

        return TextField(
          controller: controller,

          focusNode: focusNode,

          decoration:
          InputDecoration(
            labelText: 'Archetype',

            filled: true,

            fillColor: Colors.white.withOpacity(0.65,),

            border:
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12,),
            ),
          ),
        );
      },

      optionsViewBuilder:
          (
          context,
          onSelected,
          options,
          ) {

        return Material(
          elevation: 4,

          child: Container(
            constraints:
            const BoxConstraints(maxHeight: 200,),

            color: Colors.white,

            child: ListView.builder(
              shrinkWrap: true,

              itemCount: options.length,

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                final option = options.elementAt(index,);

                return ListTile(
                  title:
                  Text(option,),

                  onTap: () {

                    onSelected(option,);
                  },
                );
              },
            ),
          ),
        );
      },
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
              const EdgeInsets.all(12,),

              child: Column(
                children: [

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

                  const SizedBox(height: 12,),

                  buildAnimeField(),

                  const SizedBox(height: 12,),

                  buildArchetypeField(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}