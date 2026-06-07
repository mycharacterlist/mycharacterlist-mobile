import 'package:flutter/material.dart';

class ArchetypeField extends StatelessWidget {
  const ArchetypeField({
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
    const noneValue = '';
    final selectedValue = items.contains(controller.text)
        ? controller.text
        : noneValue;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Archetype',
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
      items: [
        const DropdownMenuItem<String>(
          value: noneValue,
          child: Text('None'),
        ),
        ...items.map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          ),
      ],
      onChanged: (value) {
        controller.text = value ?? '';
      },
    );
  }
}
