import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

class PersonalGradesDropdown extends StatefulWidget {
  const PersonalGradesDropdown({
    super.key,
    required this.definitions,
    required this.controllers,
  });

  final List<GradeDefinition> definitions;
  final Map<String, TextEditingController> controllers;

  @override
  State<PersonalGradesDropdown> createState() => _PersonalGradesDropdownState();
}

class _PersonalGradesDropdownState extends State<PersonalGradesDropdown> {
  bool isExpanded = false;

  Widget buildGradeField(GradeDefinition definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              definition.name,
              style: const TextStyle(fontSize: 25, fontFamily: 'JosefinSlab'),
            ),
          ),
          SizedBox(
            width: 45,
            height: 35,
            child: TextField(
              controller: widget.controllers[definition.id],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white.withOpacity(0.65),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '/${definition.maxValue}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Personal grades',
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
                children: widget.definitions.map(buildGradeField).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
