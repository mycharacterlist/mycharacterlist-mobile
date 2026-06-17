import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/buttons/gradient_action_button.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

class HomeButton extends StatelessWidget {
  final String text;

  final Color firstColor;
  final Color secondColor;

  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.text,
    required this.firstColor,
    required this.secondColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GradientActionButton(
      width: 280,
      height: 100,
      gradientColors: [firstColor, secondColor],
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTypography.homeButton,
      ),
    );
  }
}
