import 'package:flutter/material.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import '../widgets/character_main_information.dart';
import '../widgets/character_personal_grades.dart';
import '../widgets/character_ranks_standing.dart';
import '../widgets/character_gallery.dart';
import '../widgets/character_personal_notes.dart';

class CharacterPage extends StatelessWidget {

  const CharacterPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar: CustomAppBar(
        title: 'Character page',
        backgroundColor: const Color(0xFF315B8B),
        backButtonColor: Colors.black,
        titleColor: Colors.black,
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/CharacterPage_bg.jpg',

              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SizedBox(
              width:
              MediaQuery.of(context)
                  .size
                  .width * 0.95,

              height:
              MediaQuery.of(context)
                  .size
                  .height * 0.87,

              child: Stack(
                children: [

                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/cropped_rectangle.png',

                      fit: BoxFit.fill,
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 5,
                    right: 5,
                    bottom: 20,

                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          const SizedBox(height: 5),

                          // const Text(
                          //   'Character page',
                          //
                          //   style: TextStyle(
                          //     fontSize: 28,
                          //     color: Colors.black,
                          //     fontFamily: 'JFS',
                          //   ),
                          // ),

                          const SizedBox(height: 5),

                          const SizedBox(
                            width: double.infinity,

                            child: Text(
                              'Louise Françoise Le Blanc de La Vallière',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.black,
                                fontFamily: 'DoublePicaREG',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          const CharacterMainInformation(
                            imagePath:
                            'assets/images/LouiseTest.jpg',
                          ),

                          const SizedBox(height: 12),

                          const CharacterPersonalGrades(),

                          const SizedBox(height: 12),

                          const CharacterRanksStanding(),

                          const SizedBox(height: 12),

                          const CharacterGallery(),

                          const SizedBox(height: 12),

                          const CharacterPersonalNotes(),

                          const SizedBox(height: 12),


                          // Следующие виджеты сюда

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