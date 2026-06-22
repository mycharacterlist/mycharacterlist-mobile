import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/text/text_editing_utils.dart';

class CharacterNameField extends StatelessWidget {
  const CharacterNameField({
    super.key,
    required this.controller,
    required this.items,
    this.hasError = false,
  });

  final TextEditingController controller;
  final List<String> items;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: controller.value,
      onSelected: (value) => setCollapsedControllerText(controller, value),
      optionsBuilder: (value) {
        final query = value.text;
        if (normalizeSearchText(query).isEmpty) {
          return const Iterable<String>.empty();
        }

        return items.where((item) => matchesSearchQuery(query, item));
      },
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        return ValueListenableBuilder<TextEditingValue>(
          valueListenable: fieldController,
          builder: (context, value, _) {
            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              onChanged: (_) =>
                  syncControllerValue(controller, fieldController.value),
              decoration: InputDecoration(
                labelText: 'Name (Name, Surname)',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.65),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    color: hasError ? Colors.red : AppColors.formAccent,
                    width: 2,
                  ),
                ),
                suffixIcon: value.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          fieldController.clear();
                          syncControllerValue(controller, fieldController.value);
                        },
                        icon: const Icon(Icons.close, color: Colors.black54),
                        tooltip: 'Clear',
                      ),
              ),
            );
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  title: Text(option),
                  onTap: () => onSelected(option),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
