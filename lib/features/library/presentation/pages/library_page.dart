import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/Plus_button.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/additional_filters_card.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/filter_bottom_buttons.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/filter_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/grade_range_slider.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/library_card.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/search_bar_widget.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_search);
  }

  void _search() {
    ref
        .read(charactersViewModelProvider.notifier)
        .search(searchController.text);
  }

  void showFilterSheet() {
    final references = ref.read(characterReferencesViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFD9D4D9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          child: SingleChildScrollView(
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
                  items: references.animeTitles,
                ),
                const SizedBox(height: 5),
                FilterDropdown(
                  title: 'Archetype',
                  items: references.archetypes,
                ),
                const SizedBox(height: 5),
                const AdditionalFiltersCard(),
                const SizedBox(height: 5),
                const GradeRangeSlider(),
                const SizedBox(height: 10),
                FilterBottomButtons(onClear: () {}, onShow: () {}),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_search)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);
    ref.watch(characterReferencesViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: 'Library',
        backgroundColor: const Color(0xFF1A4043),
        backButtonColor: const Color(0xFF009768),
        titleColor: const Color(0xFF4CB897),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Library_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SearchBarWidget(
                  controller: searchController,
                  onFilterPressed: showFilterSheet,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 110),
                    child: state.isLoading && state.characters.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 5),
                              itemCount: state.characters.length,
                              itemBuilder: (context, index) {
                                final character = state.characters[index];
                                return LibraryCard(
                                  mainText: character.name,
                                  sideText: character.sourceTitle,
                                  index: index,
                                  onPressed: () => context.push(
                                    AppRoutes.characterById(character.id),
                                  ),
                                  onEditPressed: () {},
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: PlusButton(
                icon: const Icon(Icons.add, color: Colors.black, size: 45),
                onPressed: () => context.push(AppRoutes.characterCreate),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
