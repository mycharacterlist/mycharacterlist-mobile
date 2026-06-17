import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.libraryGreen,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle,
        backgroundColor: AppColors.libraryAppBarBackground,
        foregroundColor: AppColors.libraryTitle,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
