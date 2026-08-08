import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/features/gallery/presentation/widgets/character_gallery_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/Plus_button.dart';

class CharacterGalleryPage extends ConsumerWidget {

  const CharacterGalleryPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    return Scaffold(

      appBar: CustomAppBar(
        title: 'Gallery page',
        backgroundColor: const Color(0xFF024818),
        titleColor: Colors.white,
        backButtonColor: Colors.black,
      ),

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/images/Gallery_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,

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
                    bottom: 100,

                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          const SizedBox(
                            height: 5,
                          ),

                          const Text(
                            'Character name',

                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DoublePicaREG',
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          const CharacterGalleryPicker(),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 25,

            child: Center(
              child: PlusButton(
                icon: const Icon(
                  Icons.add,
                  size: 40,
                  color: Colors.white,
                ),

                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}