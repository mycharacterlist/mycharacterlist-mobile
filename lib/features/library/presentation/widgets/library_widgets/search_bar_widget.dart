import 'package:flutter/material.dart';
import 'filter_button.dart';

class SearchBarWidget
    extends StatelessWidget {

  final TextEditingController controller;

  final VoidCallback onFilterPressed;

  const SearchBarWidget({
    super.key,

    required this.controller,

    required this.onFilterPressed,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 15,
      ),

      child: Row(
        children: [

          Expanded(
            child: Container(
              height: 60,

              decoration:
              BoxDecoration(
                color: const Color(0xFFD9D4D9,),

                borderRadius: BorderRadius.circular(22,),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25,),
                    blurRadius: 12,
                    offset: const Offset(0, 5,),
                  ),
                ],
              ),

              child: Row(
                children: [

                  const SizedBox(width: 12,),

                  const Icon(
                    Icons.search,
                    size: 40,
                    color: Colors.black54,
                  ),

                  const SizedBox(width: 8,),

                  Expanded(
                    child: TextField(
                      controller: controller,

                      decoration:
                      const InputDecoration(
                        hintText: 'Search',

                        hintStyle:
                        TextStyle(color: Colors.black54,

                          fontSize: 24,
                          fontFamily: 'JosefinSlab',
                          fontWeight: FontWeight.bold,
                        ),

                        border: InputBorder.none,
                      ),

                      style:
                      const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'JosefinSlab',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10,),

          FilterButton(
            onPressed: onFilterPressed,
          ),
        ],
      ),
    );
  }
}