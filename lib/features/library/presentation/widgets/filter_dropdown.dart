import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {

  final String title;

  final List<String> items;

  final GlobalKey<
      _FilterDropdownState>?
  clearKey;

  const FilterDropdown({
    super.key,

    required this.title,

    required this.items,

    this.clearKey,
  });

  @override
  State<FilterDropdown>
  createState() =>
      _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {

  bool isExpanded = false;

  final List<String> selected = [];

  void clearFilters() {

    setState(() {

      selected.clear();
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      key: widget.clearKey,

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
                        fontSize: 37,
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

            Container(
              constraints:
              const BoxConstraints(maxHeight: 220,),

              child: Scrollbar(
                thumbVisibility: true,

                child: ListView.builder(
                  shrinkWrap: true,

                  itemCount: widget.items.length,

                  itemBuilder:
                      (context,
                      index) {

                    final item = widget.items[index];

                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),

                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.center,

                        children: [

                          Expanded(
                            child: Padding(
                              padding:
                              const EdgeInsets.only(left: 8,),

                              child: Text(
                                item,

                                softWrap: true,

                                style:
                                const TextStyle(
                                  fontSize: 28,
                                  fontFamily: 'JosefinSlab',
                                ),
                              ),
                            ),
                          ),

                          Checkbox(
                            value:
                            selected.contains(
                              item,
                            ),

                            activeColor: Colors.black,

                            onChanged:
                                (value) {

                              setState(() {

                                if (value == true
                                ) {

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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}