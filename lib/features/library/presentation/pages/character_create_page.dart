import 'package:flutter/material.dart';
import '../../../../app/widgets/app_appbar.dart';
import '../widgets/character_create_widgets/main_photo_picker.dart';
import '../widgets/character_create_widgets/main_information_dropdown.dart';

class CharacterCreatePage extends StatelessWidget {
  const CharacterCreatePage({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar:
      CustomAppBar(
        title:
        'New Character',

        backgroundColor: const Color(0xFF1A4043,),

        backButtonColor: const Color(0xFF009768,),

        titleColor: const Color(0xFF4CB897,),
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/Library_bg.jpg',

              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: SizedBox(
              width:
              MediaQuery.of(context)
                  .size
                  .width * 0.90,

              height:
              MediaQuery.of(context)
                  .size
                  .height * 0.87,

              child: Stack(
                children: [

                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/PagePictureFixed.png',

                      fit: BoxFit.fill,
                    ),
                  ),

                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    bottom: 20,

                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          const SizedBox(height: 17,),

                          Center(
                            child: Text(
                              'New character',

                              style: TextStyle(
                                fontSize: 45,
                                color: Colors.black,
                                fontFamily: 'GreatVibes',
                              ),
                            ),
                          ),

                          const SizedBox(height: 20,),

                          const Align(
                            alignment: Alignment.centerLeft,

                            child: MainPhotoPicker(),
                          ),

                          const SizedBox(height: 25,),

                          const MainInformationDropdown(),

                          const SizedBox(height: 25,),

                          // Следующие виджеты добавлять сюда
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