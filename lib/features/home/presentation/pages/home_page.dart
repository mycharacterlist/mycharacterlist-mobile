import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import '../widgets/home_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/HomePage_bg.jpeg'),
            fit: BoxFit.cover,
          ),
        ),

        child: Column(
          children: [
            const Spacer(),

            const Text(
              'My anime\nCharacter List',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'JpAnimeFont',
                fontSize: 48,
              ),
            ),

            const Spacer(),

            HomeButton(
              text: 'My Lists',
              firstColor: const Color(0xFFD9D9D9),
              secondColor: const Color(0xFF805858),
              onPressed: () {
                context.push(AppRoutes.lists);
              },
            ),

            const SizedBox(height: 20),

            HomeButton(
              text: 'Library',
              firstColor: const Color(0xFFD9D9D9),
              secondColor: const Color(0xFFE73D3D),
              onPressed: () {},
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}