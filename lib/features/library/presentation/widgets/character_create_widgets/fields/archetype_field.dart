import 'package:flutter/material.dart';

class ArchetypeField extends StatelessWidget {

  const ArchetypeField({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    final List<String>
    archetypes = [
      'Dandere',
      'Deredere',
      'Himedere',
      'Kuudere',
      'Tsundere',
      'Yandere',
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

        return archetypes.where(
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
            labelText: 'Archetype',
            filled: true,
            fillColor: Colors.white.withOpacity(0.65,),

            border:
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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
            const BoxConstraints(maxHeight: 200,),
            color: Colors.white,

            child: ListView.builder(
              shrinkWrap:
              true,

              itemCount:
              options.length,

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
                  Text(option,),

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