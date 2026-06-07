import 'package:flutter/material.dart';

class PersonalNotesDropdown extends StatefulWidget {
  const PersonalNotesDropdown({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PersonalNotesDropdown> createState() => _PersonalNotesDropdownState();
}

class _PersonalNotesDropdownState extends State<PersonalNotesDropdown> {
  bool isExpanded = false;

  static const int maxSymbols = 350;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
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
                      'Personal notes',

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
                  TextField(
                    controller: widget.controller,
                    maxLength: maxSymbols,
                    maxLines: 6,

                    decoration: InputDecoration(
                      hintText: 'Input text',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.65),

                      counterText:
                          'Symbols (${widget.controller.text.length}/350)',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(color: Color(0xFF7B61FF)),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(color: Color(0xFF7B61FF)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(
                          color: Color(0xFF7B61FF),
                          width: 2,
                        ),
                      ),
                    ),

                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
