import 'package:flutter/material.dart';

class AnimeField extends StatelessWidget {

  const AnimeField({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    final List<String>
    animeList = [
      'Code Geass',
      'Naruto',
      'Bleach',
      'Attack on Titan',
      'Classroom of the Elite',
      'Death Note',
    ];

    return Autocomplete<String>(
      optionsBuilder:
          (
          TextEditingValue
          textEditingValue,
          ) {

        if (textEditingValue.text.isEmpty)
        {
          return const Iterable<
              String>.empty();
        }

        return animeList.where(
              (item) {

            return item
                .toLowerCase()
                .startsWith(
              textEditingValue
                  .text
                  .toLowerCase(),
            );
          },
        );
      },

      fieldViewBuilder:
          (
          context,
          controller,
          focusNode,
          onFieldSubmitted,
          ) {

        return TextField(
          controller: controller,
          focusNode: focusNode,

          decoration:
          InputDecoration(
            labelText: 'Anime',
            filled: true,
            fillColor: Colors.white.withOpacity(0.65,),

            border:
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            suffixIcon:
            Padding(
              padding: const EdgeInsets.all(4),

              child:
              ElevatedButton(
                onPressed: () {},

                style:
                ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: const Color(0xFF7B61FF),

                  side:
                  const BorderSide(
                    color: Color(0xFF7B61FF),
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child:
                const Text('New+'),
              ),
            ),

            suffixIconConstraints:
            const BoxConstraints(
              minWidth: 90,
              minHeight: 40,
            ),
          ),
        );
      },

      optionsViewBuilder:
          (
          context,
          onSelected,
          options,
          ) {

        return Material(
          elevation: 4,

          child: Container(
            constraints:
            const BoxConstraints(maxHeight: 200),

            color:
            Colors.white,

            child: ListView.builder(
              shrinkWrap: true,

              itemCount: options.length,

              itemBuilder:
                  (
                  context,
                  index,
                  ) {

                final option =
                options.elementAt(
                  index,
                );

                return ListTile(
                  title:
                  Text(
                    option,
                  ),

                  onTap: () {

                    onSelected(
                      option,
                    );
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