import 'package:flutter/material.dart';

class FilterDropdown
    extends StatefulWidget {

  final String title;

  final List<String> items;

  const FilterDropdown({
    super.key,

    required this.title,

    required this.items,
  });

  @override
  State<FilterDropdown>
  createState() =>
      _FilterDropdownState();
}

class _FilterDropdownState
    extends State<FilterDropdown> {

  bool isExpanded = false;

  final List<String> selected = [];

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration:
      BoxDecoration(
        color: const Color(0xFFE9E9E9,),

        borderRadius: BorderRadius.circular(18,),
      ),

      child: Column(
        children: [

          InkWell(
            borderRadius: BorderRadius.circular(18,),

            onTap: () {

              setState(() {

                isExpanded = !isExpanded;
              });
            },

            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      widget.title,

                      style:
                      const TextStyle(
                        fontSize: 30,
                        fontFamily: 'JosefinSlab',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,

                    size: 38,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)

            Column(
              children:
              widget.items.map(
                    (item) {

                  return CheckboxListTile(
                    value: selected.contains(item,),

                    activeColor: Colors.black,

                    title: Text(
                      item,

                      style:
                      const TextStyle(
                        fontSize: 25,
                        fontFamily: 'JosefinSlab',
                      ),
                    ),

                    onChanged:
                        (value) {

                      setState(() {

                        if (value ==
                            true) {

                          selected.add(
                            item,
                          );
                        }

                        else {

                          selected.remove(
                            item,
                          );
                        }
                      });
                    },
                  );
                },
              ).toList(),
            ),
        ],
      ),
    );
  }
}