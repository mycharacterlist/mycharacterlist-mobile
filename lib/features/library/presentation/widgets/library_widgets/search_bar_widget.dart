import 'package:flutter/material.dart';
import 'filter_button.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  final ValueChanged<String> onChanged;
  final VoidCallback onClearPressed;

  final VoidCallback onFilterPressed;

  const SearchBarWidget({
    super.key,

    required this.controller,

    required this.onChanged,
    required this.onClearPressed,

    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),

      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,

              decoration: BoxDecoration(
                color: const Color(0xFFD9D4D9),

                borderRadius: BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Row(
                children: [
                  const SizedBox(width: 12),

                  const Icon(Icons.search, size: 40, color: Colors.black54),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,

                      decoration: const InputDecoration(
                        hintText: 'Search',

                        hintStyle: TextStyle(
                          color: Colors.black54,

                          fontSize: 24,
                          fontFamily: 'JosefinSlab',
                          fontWeight: FontWeight.bold,
                        ),

                        border: InputBorder.none,
                      ),

                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'JosefinSlab',
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) {
                        return const SizedBox(width: 8);
                      }

                      return IconButton(
                        onPressed: onClearPressed,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black54,
                          size: 26,
                        ),
                        tooltip: 'Clear search',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          FilterButton(onPressed: onFilterPressed),
        ],
      ),
    );
  }
}
