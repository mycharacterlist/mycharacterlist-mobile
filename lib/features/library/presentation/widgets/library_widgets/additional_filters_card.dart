import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class AdditionalFiltersCard extends StatefulWidget {
  const AdditionalFiltersCard({
    super.key,
    this.initialGenders = const {},
    this.initialPositions = const {},
    required this.onChanged,
  });

  final Set<String> initialGenders;
  final Set<String> initialPositions;
  final void Function(Set<String> genders, Set<String> positions) onChanged;

  @override
  State<AdditionalFiltersCard> createState() => _AdditionalFiltersCardState();
}

class _AdditionalFiltersCardState extends State<AdditionalFiltersCard> {
  bool isExpanded = false;

  final List<String> selectedGender = [];

  final List<String> selectedPosition = [];

  @override
  void initState() {
    super.initState();
    selectedGender.addAll(
      widget.initialGenders.map(
        (gender) => '${gender[0].toUpperCase()}${gender.substring(1)}',
      ),
    );
    selectedPosition.addAll(widget.initialPositions);
  }

  Widget buildCheckboxItem(String item, List<String> selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),

              child: Text(
                item,

                style: const TextStyle(fontSize: 28, fontFamily: 'JosefinSlab'),
              ),
            ),
          ),

          Checkbox(
            value: selected.contains(item),

            activeColor: Colors.black,

            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selected.add(item);
                } else {
                  selected.remove(item);
                }
                widget.onChanged(
                  selectedGender.map((value) => value.toLowerCase()).toSet(),
                  selectedPosition.toSet(),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.filterCard,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),

            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },

            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Additional filters',

                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'JosefinSlab',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,

                  size: 38,

                  color: Colors.black54,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            const SizedBox(height: 20),

            const Text(
              'Gender',

              style: TextStyle(
                fontSize: 28,
                fontFamily: 'JosefinSlab',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(child: buildCheckboxItem('Male', selectedGender)),

                Expanded(child: buildCheckboxItem('Female', selectedGender)),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Position',

              style: TextStyle(
                fontSize: 28,
                fontFamily: 'JosefinSlab',
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            buildCheckboxItem('#1', selectedPosition),

            buildCheckboxItem('Podium', selectedPosition),

            buildCheckboxItem('In lists', selectedPosition),

            buildCheckboxItem('Out of lists', selectedPosition),
          ],
        ],
      ),
    );
  }
}
