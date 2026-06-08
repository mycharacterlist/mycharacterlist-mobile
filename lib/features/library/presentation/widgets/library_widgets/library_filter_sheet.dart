import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/library/domain/entities/character_filters.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/additional_filters_card.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/filter_bottom_buttons.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/filter_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/grade_range_slider.dart';

class LibraryFilterSheet extends StatefulWidget {
  const LibraryFilterSheet({
    super.key,
    required this.filters,
    required this.animeTitles,
    required this.archetypes,
    required this.onClear,
    required this.onApply,
  });

  final CharacterFilters filters;
  final List<String> animeTitles;
  final List<String> archetypes;
  final VoidCallback onClear;
  final ValueChanged<CharacterFilters> onApply;

  @override
  State<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<LibraryFilterSheet> {
  final scrollController = ScrollController();
  late Set<String> animeTitles;
  late Set<String> archetypes;
  late Set<String> genders;
  late Set<String> positions;
  late RangeValues gradeRange;

  @override
  void initState() {
    super.initState();
    final filters = widget.filters;
    animeTitles = {...filters.animeTitles};
    archetypes = {...filters.archetypes};
    genders = {...filters.genders};
    positions = {...filters.positions};
    gradeRange = RangeValues(filters.minOverallGrade, filters.maxOverallGrade);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'FrancoisOne',
              ),
            ),
            const SizedBox(height: 20),
            FilterDropdown(
              title: 'Anime',
              items: widget.animeTitles,
              initialSelected: animeTitles,
              onChanged: (value) => animeTitles = value,
            ),
            const SizedBox(height: 5),
            FilterDropdown(
              title: 'Archetype',
              items: widget.archetypes,
              initialSelected: archetypes,
              onChanged: (value) => archetypes = value,
            ),
            const SizedBox(height: 5),
            AdditionalFiltersCard(
              initialGenders: genders,
              initialPositions: positions,
              onChanged: (selectedGenders, selectedPositions) {
                genders = selectedGenders;
                positions = selectedPositions;
              },
            ),
            const SizedBox(height: 5),
            GradeRangeSlider(
              initialValues: gradeRange,
              onChanged: (value) => gradeRange = value,
            ),
            const SizedBox(height: 10),
            FilterBottomButtons(onClear: widget.onClear, onShow: _apply),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _apply() {
    widget.onApply(
      CharacterFilters(
        animeTitles: animeTitles,
        archetypes: archetypes,
        genders: genders,
        positions: positions,
        minOverallGrade: gradeRange.start,
        maxOverallGrade: gradeRange.end,
      ),
    );
  }
}
