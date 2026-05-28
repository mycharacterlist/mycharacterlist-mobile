import 'package:flutter/material.dart';

import '../../../../app/widgets/app_appbar.dart';
import '../widgets/Plus_button.dart';
import '../widgets/library_card.dart';
import '../widgets/create_character_dialog.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_dropdown.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() =>
      _LibraryPageState();
}

class _LibraryPageState
    extends State<LibraryPage> {

  final List<Map<String, String>>
  cards = [];

  final TextEditingController
  mainController = TextEditingController();

  final TextEditingController
  sideController = TextEditingController();

  final TextEditingController
  searchController = TextEditingController();

  void showCreateDialog() {

    CreateCharacterDialog.show(
      context: context,

      mainController: mainController,

      sideController: sideController,

      onCreate: () {

        if (
        mainController.text.isNotEmpty
        ) {

          setState(() {

            cards.add({

              'main': mainController.text,

              'side': sideController.text,
            });
          });

          mainController.clear();
          sideController.clear();

          Navigator.pop(context);
        }
      },
    );
  }

  void showFilterSheet() {

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor:
      const Color(0xFFD9D4D9,),

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.only(
          topLeft:
          Radius.circular(30,),

          topRight:
          Radius.circular(30,),
        ),
      ),

      clipBehavior:
      Clip.antiAlias,

      builder: (context) {

        return Container(
          width:
          double.infinity,

          height:
          MediaQuery.of(context).size.height * 0.75,

          child: Column(
            children: [

              const SizedBox(height: 20,),

              Container(
                width: 60,
                height: 5,

                decoration:
                BoxDecoration(
                  color: Colors.black26,

                  borderRadius: BorderRadius.circular(10,),
                ),
              ),

              const SizedBox(height: 20,),

              const Text(
                'Filter',

                style:
                TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FrancoisOne',
                ),
              ),

              const SizedBox(height: 20,),

              const FilterDropdown(
                title: 'Anime',

                items: [
                  'Naruto',
                  'Bleach',
                  'Code Geass',
                  'Attack on Titan',
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    padding:
                    const EdgeInsets.only(bottom: 110,),

                    child: Scrollbar(
                      thumbVisibility: true,

                      child: ListView(
                        padding:
                        const EdgeInsets.only(top: 5,),

                        children: [

                          ...cards.asMap().entries.map(
                                (entry) {

                              final index = entry.key;

                              final card = entry.value;

                              return LibraryCard(
                                mainText: card['main']!,

                                sideText: card['side']!,

                                index: index,

                                onPressed: () {},

                                onEditPressed: () {},
                              );
                            },
                          ),
                        ],
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
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 45,
                ),

                onPressed:
                showCreateDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}