import 'package:flutter/material.dart';
import '../../../../app/widgets/app_appbar.dart';
import '../widgets/Plus_button.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}