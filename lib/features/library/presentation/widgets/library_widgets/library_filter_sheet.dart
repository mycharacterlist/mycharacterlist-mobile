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
    this.scrollController,
  });

  final CharacterFilters filters;
  final List<String> animeTitles;
  final List<String> archetypes;
  final VoidCallback onClear;
  final ValueChanged<CharacterFilters> onApply;
  final ScrollController? scrollController;

  @override
  State<LibraryFilterSheet> createState() => _LibraryFilterSheetState();
}

class _LibraryFilterSheetState extends State<LibraryFilterSheet> {
  ScrollController? _ownedScrollController;
  late Set<String> animeTitles;
  late Set<String> archetypes;
  late Set<String> genders;
  late Set<String> positions;
  late RangeValues gradeRange;

  ScrollController get _scrollController =>
      widget.scrollController ?? _ownedScrollController!;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _ownedScrollController = ScrollController();
    }
    final filters = widget.filters;
    animeTitles = {...filters.animeTitles};
    archetypes = {...filters.archetypes};
    genders = {...filters.genders};
    positions = {...filters.positions};
    gradeRange = RangeValues(filters.minOverallGrade, filters.maxOverallGrade);
  }

  @override
  void dispose() {
    _ownedScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FilterSheetHeader(),
        Expanded(
          child: ListView(
            controller: _scrollController,
            children: [
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
              SizedBox(
                height: 10 + MediaQuery.viewPaddingOf(context).bottom,
              ),
            ],
          ),
        ),
      ],
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

class _FilterSheetHeader extends StatefulWidget {
  const _FilterSheetHeader();

  @override
  State<_FilterSheetHeader> createState() => _FilterSheetHeaderState();
}

class _FilterSheetHeaderState extends State<_FilterSheetHeader> {
  double _dragDistance = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          _dragDistance += details.delta.dy;
        }
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (_dragDistance > 48 || velocity > 300) {
          Navigator.of(context).pop();
        }
        _dragDistance = 0;
      },
      child: const Column(
        children: [
          SizedBox(height: 12),
          _FilterSheetHandle(),
          SizedBox(height: 16),
          Text(
            'Filter',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'FrancoisOne',
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterSheetHandle extends StatelessWidget {
  const _FilterSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
