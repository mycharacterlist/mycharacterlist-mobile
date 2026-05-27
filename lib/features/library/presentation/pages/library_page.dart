import 'package:flutter/material.dart';

import '../../../../app/widgets/app_appbar.dart';
import '../widgets/Plus_button.dart';
import '../widgets/library_card.dart';
import '../widgets/create_character_dialog.dart';
import '../widgets/search_bar_widget.dart';

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
  mainController =
  TextEditingController();

  final TextEditingController
  sideController =
  TextEditingController();

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

              'main':
              mainController.text,

              'side':
              sideController.text,
            });
          });

          mainController.clear();
          sideController.clear();

          Navigator.pop(context,);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: CustomAppBar(
        title: 'Library',

        backgroundColor:
        const Color(0xFF1A4043),

        backButtonColor:
        const Color(0xFF009768),

        titleColor:
        const Color(0xFF4CB897),
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
            child: Padding(
              padding:
              const EdgeInsets.only(
                bottom: 105,
              ),

              child: Scrollbar(
                thumbVisibility:
                true,

                child: ListView(
                  padding:
                  const EdgeInsets.only(
                    top: 20,
                  ),

                  children: [

                    const SearchBarWidget(),

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

          Positioned(
            left: 0,
            right: 0,
            bottom: 35,

            child: Center(
              child: PlusButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 45,
                ),

                onPressed: showCreateDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }
}