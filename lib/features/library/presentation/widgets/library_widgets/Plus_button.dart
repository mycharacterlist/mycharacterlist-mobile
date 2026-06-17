import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/buttons/gradient_action_button.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';

class PlusButton extends StatelessWidget {
  final Icon icon;

  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const PlusButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GradientActionButton(
      width: 60,
      height: 60,
      borderRadius: 20,
      gradientBegin: Alignment.topCenter,
      gradientEnd: Alignment.bottomCenter,
      gradientColors: const [
        AppColors.libraryGreen,
        AppColors.libraryGreenDarker,
      ],
      onPressed: onPressed,
      onLongPress: onLongPress,
      padding: EdgeInsets.zero,
      child: icon,
    );
  }
}
