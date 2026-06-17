import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

abstract final class RankingMedalColors {
  static Color badgeColorForPosition(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFE6E600);
      case 2:
        return const Color(0xFF898985);
      case 3:
        return const Color(0xFF935712);
      default:
        return const Color(0xFF9996DF);
    }
  }

  static LinearGradient cardGradientForPosition(int index) {
    switch (index) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFFD6C), AppColors.neutralGray],
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF979794), AppColors.neutralGray],
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF9B4D22), AppColors.neutralGray],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFC8C3FA), AppColors.neutralGray],
        );
    }
  }

  static LinearGradient titleGradientForPosition(int index) {
    switch (index) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFF8001), Color(0xFFCAC300)],
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF4D4B49), Color(0xFF979794)],
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF3C2207), Color(0xFFEBA5A5)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF3424EE)],
        );
    }
  }
}
