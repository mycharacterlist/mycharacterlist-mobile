import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/features/compare/presentation/widgets/compare_character_picker.dart';
import 'package:mycharacterlist/features/compare/presentation/widgets/compare_stat_row.dart';

class CompareCharactersPage extends ConsumerStatefulWidget {
  const CompareCharactersPage({
    super.key,
  });

  @override
  ConsumerState<CompareCharactersPage> createState() =>
      _CompareCharactersPageState();
}

class _CompareCharactersPageState
    extends ConsumerState<CompareCharactersPage> {

  final ScrollController _scrollController =
  ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Compare page',
        backgroundColor: const Color(0xFF0D0F24),
        titleColor: const Color(0xFFFDFFCD),
        backButtonColor: const Color(0xFFFDFFCD),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/Compare_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: 5,
            left: 10,
            right: 10,
            bottom: 15,

            child: Image.asset(
              'assets/images/cropped_rectangle_gray.png',
              fit: BoxFit.fill,
            ),
          ),

          Positioned(
            top: 5,
            left: 10,
            right: 10,
            bottom: 15,

            child: Padding(
              padding: const EdgeInsets.all(10),

              child: Column(
                children: [

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      const Expanded(
                        child: CompareCharacterPicker(),
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      const Expanded(
                        child: CompareCharacterPicker(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [

                      const Expanded(
                        child: Text(
                          'Character name',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      const Expanded(
                        child: Text(
                          'Character name',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'JosefinSans',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Row(
                    children: [

                      const Expanded(
                        child: Text(
                          'Anime name',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: 'Jura',
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 20,
                      ),

                      const Expanded(
                        child: Text(
                          'Anime name',
                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontFamily: 'Jura',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 5,
                      radius: const Radius.circular(10),

                      child: ListView(
                        controller: _scrollController,

                        padding:
                        const EdgeInsets.only(
                          right: 8,
                          bottom: 20,
                        ),

                        children: [

                          const CompareStatRow(
                            leftValue: '9.0',
                            title: 'Overall grade',
                            rightValue: '8.2',
                            rightColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '10',
                            title: 'Appearance',
                            rightValue: '9',
                            rightColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '9',
                            title: 'Character',
                            rightValue: '9',
                            rightColor: Color(0xFF9E9E9E),
                            leftColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '9',
                            title: 'Outfit',
                            rightValue: '8',
                            rightColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '9',
                            title: 'Haircut',
                            rightValue: '7',
                            rightColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '8',
                            title: 'Eyes',
                            rightValue: '8',
                            rightColor: Color(0xFF9E9E9E),
                            leftColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '#12',
                            title: 'Highest rank position',
                            rightValue: '#3',
                            leftColor: Color(0xFF9E9E9E),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '17',
                            title: 'Age',
                            rightValue: '18',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: '167',
                            title: 'Height',
                            rightValue: '159',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          const CompareStatRow(
                            leftValue: 'Tsundere',
                            title: 'Archetype',
                            rightValue: 'Deredere',
                            leftFontSize: 22,
                            rightFontSize: 22,
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}