import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class ScreenAppBarStyle {
  const ScreenAppBarStyle({
    required this.backgroundColor,
    required this.backButtonColor,
    required this.titleColor,
  });

  final Color backgroundColor;
  final Color backButtonColor;
  final Color titleColor;
}

abstract final class AppScreenAppBars {
  static const library = ScreenAppBarStyle(
    backgroundColor: AppColors.libraryAppBarBackground,
    backButtonColor: AppColors.libraryGreen,
    titleColor: AppColors.libraryTitle,
  );

  static const lists = ScreenAppBarStyle(
    backgroundColor: AppColors.listsAppBarBackground,
    backButtonColor: AppColors.listsMagenta,
    titleColor: AppColors.listsMagenta,
  );

  static const character = ScreenAppBarStyle(
    backgroundColor: AppColors.characterAppBarBackground,
    backButtonColor: Colors.white,
    titleColor: Colors.white,
  );

  static const ranking = ScreenAppBarStyle(
    backgroundColor: AppColors.rankingAppBarBackground,
    backButtonColor: Colors.white,
    titleColor: Colors.white,
  );
}
