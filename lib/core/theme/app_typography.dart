import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

abstract final class AppTypography {
  static const characterSectionTitle = TextStyle(
    fontSize: 32,
    color: Colors.black,
    fontFamily: 'Joan',
  );

  static const characterSectionEmpty = TextStyle(
    fontSize: 22,
    color: Colors.black,
    fontFamily: 'Joan',
  );

  static const homeButton = TextStyle(
    fontSize: 35,
    color: Colors.black,
    fontFamily: 'LibreCaslonText',
    fontWeight: FontWeight.bold,
  );

  static const createNewButton = TextStyle(
    color: AppColors.listsGold,
    fontFamily: 'JpAnimeFont',
    fontSize: 30,
  );

  static const loadingOverlayTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'FrancoisOne',
  );

  static const loadingOverlayProgress = TextStyle(
    color: Colors.white70,
    fontSize: 16,
  );

  static const appBarTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    fontFamily: 'JosefinSans',
  );

  static const inlineMessage = TextStyle(
    fontSize: 20,
    color: Colors.black,
  );
}
