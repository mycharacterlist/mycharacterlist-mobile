import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_background_image.dart';
import '../widgets/home_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppBackgroundImage(
            assetPath: AppBackgroundAssets.home,
          ),
          Column(
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
              onPressed: () {
                context.push(AppRoutes.library);
              },
            ),

            const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}