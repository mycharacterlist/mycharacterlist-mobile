import 'package:flutter/material.dart';

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
      onSelected: (value) => controller.text = value,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) {
          return const Iterable<String>.empty();
        }

        return items.where((item) => item.toLowerCase().contains(query));
      },
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (value) => controller.text = value,
          decoration: InputDecoration(
            labelText: 'Name (Name, Surname)',
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.65),
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
