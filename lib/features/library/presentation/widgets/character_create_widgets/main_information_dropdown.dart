import 'package:flutter/material.dart';
import 'gender_selector.dart';
import 'fields/archetype_field.dart';
import 'fields/anime_field.dart';
import 'fields/character_name_field.dart';

class MainInformationDropdown extends StatefulWidget {
  const MainInformationDropdown({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.heightController,
    required this.japaneseNameController,
    required this.animeController,
    required this.archetypeController,
    required this.characterNames,
    required this.animeTitles,
    required this.archetypes,
    required this.selectedGender,
    required this.onGenderChanged,
    this.nameHasError = false,
    this.animeHasError = false,
    this.archetypeHasError = false,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController japaneseNameController;
  final TextEditingController animeController;
  final TextEditingController archetypeController;
  final List<String> characterNames;
  final List<String> animeTitles;
  final List<String> archetypes;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;
  final bool nameHasError;
  final bool animeHasError;
  final bool archetypeHasError;

  @override
  State<MainInformationDropdown> createState() =>
      _MainInformationDropdownState();
}

class _MainInformationDropdownState extends State<MainInformationDropdown> {
  bool isExpanded = false;

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool hasError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.65),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey,
              width: hasError ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: hasError ? Colors.red : const Color(0xFF7B61FF),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError =
        widget.nameHasError || widget.animeHasError || widget.archetypeHasError;

    if (hasError && !isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !isExpanded) {
          setState(() => isExpanded = true);
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,

        border: Border.all(color: Colors.black, width: 2),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Main information',

                      style: TextStyle(
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
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [
                  GenderSelector(
                    selectedGender: widget.selectedGender,
                    onChanged: widget.onGenderChanged,
                  ),

                  const SizedBox(height: 12),

                  CharacterNameField(
                    controller: widget.nameController,
                    items: widget.characterNames,
                    hasError: widget.nameHasError,
                  ),

                  const SizedBox(height: 12),

                  buildField('Age', widget.ageController),

                  buildField('Height (cm)', widget.heightController),

                  buildField('Japanese name', widget.japaneseNameController),

                  const SizedBox(height: 12),

                  AnimeField(
                    controller: widget.animeController,
                    items: widget.animeTitles,
                    hasError: widget.animeHasError,
                  ),

                  const SizedBox(height: 12),

                  ArchetypeField(
                    controller: widget.archetypeController,
                    items: widget.archetypes,
                    hasError: widget.archetypeHasError,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
