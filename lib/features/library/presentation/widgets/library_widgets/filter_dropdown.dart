import 'package:flutter/material.dart';

class FilterDropdown extends StatefulWidget {
  final String title;

  final List<String> items;

  final Set<String> initialSelected;

  final ValueChanged<Set<String>> onChanged;

  final GlobalKey<_FilterDropdownState>? clearKey;

  const FilterDropdown({
    super.key,

    required this.title,

    required this.items,

    this.initialSelected = const {},

    required this.onChanged,

    this.clearKey,
  });

  @override
  State<FilterDropdown> createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  bool isExpanded = false;
  final scrollController = ScrollController();

  final List<String> selected = [];

  @override
  void initState() {
    super.initState();
    selected.addAll(widget.initialSelected);
  }

  void clearFilters() {
    setState(() {
      selected.clear();
    });
    widget.onChanged({});
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.clearKey,

      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: BoxDecoration(
        color: const Color(0xFFE9E9E9),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),

            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,

                      style: const TextStyle(
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
              constraints: const BoxConstraints(maxHeight: 220),

              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,

                child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,

                  itemCount: widget.items.length,

                  itemBuilder: (context, index) {
                    final item = widget.items[index];

                    return InkWell(
                      onTap: () => _toggleItem(item),
                      child: Container(
                        padding: const EdgeInsets.only(left: 18, right: 10),
                        decoration: BoxDecoration(
                          border: index == widget.items.length - 1
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                item,
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontFamily: 'JosefinSlab',
                                ),
                              ),
                            ),
                            Checkbox(
                              value: selected.contains(item),
                              activeColor: Colors.black,
                              onChanged: (_) => _toggleItem(item),
                            ),
                          ],
                        ),
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

  void _toggleItem(String item) {
    setState(() {
      if (selected.contains(item)) {
        selected.remove(item);
      } else {
        selected.add(item);
      }
      widget.onChanged(selected.toSet());
    });
  }
}
