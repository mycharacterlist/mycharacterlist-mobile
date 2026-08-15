import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import '../widgets/home_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return ScreenScaffold(
      backgroundAssetPath: AppBackgroundAssets.home,
      child: Padding(
        padding: viewPadding,
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
              firstColor: AppColors.homeGray,
              secondColor: AppColors.homeBrown,
              onPressed: () => context.push(AppRoutes.lists),
            ),
            const SizedBox(height: 20),
            HomeButton(
              text: 'Library',
              firstColor: AppColors.homeGray,
              secondColor: AppColors.homeRed,
              onPressed: () => context.push(AppRoutes.library),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
