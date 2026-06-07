import 'package:flutter/material.dart';

class AnimeField extends StatelessWidget {
  const AnimeField({
    super.key,
    required this.controller,
    required this.items,
    required this.onAdd,
    this.hasError = false,
  });

  final TextEditingController controller;
  final List<String> items;
  final VoidCallback onAdd;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: controller.value,
      onSelected: (value) => controller.text = value,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }

        return items.where((item) {
          return item.toLowerCase().startsWith(
            textEditingValue.text.toLowerCase(),
          );
        });
      },

      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (value) => this.controller.text = value,

          decoration: InputDecoration(
            labelText: 'Anime',
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

            suffixIcon: Padding(
              padding: const EdgeInsets.all(4),

              child: ElevatedButton(
                onPressed: onAdd,

                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF7B61FF),

                  side: const BorderSide(color: Color(0xFF7B61FF)),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: const Text('New+'),
              ),
            ),

            suffixIconConstraints: const BoxConstraints(
              minWidth: 90,
              minHeight: 40,
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

                  onTap: () {
                    onSelected(option);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
