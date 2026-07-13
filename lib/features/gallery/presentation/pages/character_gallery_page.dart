import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';

class CharacterGalleryPage
    extends ConsumerWidget {

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
        titleColor: const Color(0xFFFFFFFF),
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

                          const SizedBox(
                            height: 5,
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
