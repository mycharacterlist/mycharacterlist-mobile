import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class PersonalNotesDropdown extends StatefulWidget {
  const PersonalNotesDropdown({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<PersonalNotesDropdown> createState() => _PersonalNotesDropdownState();
}

class _PersonalNotesDropdownState extends State<PersonalNotesDropdown> {
  final FocusNode _notesFocusNode = FocusNode();
  final GlobalKey _notesFieldKey = GlobalKey();
  bool isExpanded = false;

  static const int maxSymbols = 350;

  @override
  void initState() {
    super.initState();
    _notesFocusNode.addListener(_ensureNotesVisible);
  }

  @override
  void dispose() {
    _notesFocusNode.removeListener(_ensureNotesVisible);
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _ensureNotesVisible({bool force = false}) {
    if (!force && !_notesFocusNode.hasFocus) {
      return;
    }

    void scrollIntoView() {
      if (!mounted) {
        return;
      }

      final notesFieldContext = _notesFieldKey.currentContext;
      if (notesFieldContext == null) {
        return;
      }

      Scrollable.ensureVisible(
        notesFieldContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: 0.28,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollIntoView();
    });
    Future<void>.delayed(
      const Duration(milliseconds: 350),
      scrollIntoView,
    );
    Future<void>.delayed(
      const Duration(milliseconds: 700),
      scrollIntoView,
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final keyboardInset = view.viewInsets.bottom / view.devicePixelRatio;

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

              if (!isExpanded) {
                return;
              }

              _ensureNotesVisible(force: true);
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
              key: _notesFieldKey,
              padding: const EdgeInsets.all(12),

              child: Column(
                children: [
                  TextField(
                    controller: widget.controller,
                    focusNode: _notesFocusNode,
                    maxLength: maxSymbols,
                    maxLines: 6,
                    scrollPadding: EdgeInsets.only(
                      bottom: keyboardInset + 80,
                    ),
                    onTap: () => _ensureNotesVisible(force: true),

                    decoration: InputDecoration(
                      hintText: 'Input text',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.65),

                      counterText:
                          'Symbols (${widget.controller.text.length}/350)',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(color: AppColors.formAccent),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(color: AppColors.formAccent),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),

                        borderSide: const BorderSide(
                          color: AppColors.formAccent,
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
