import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/buttons/gradient_action_button.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

class CreateNewButton extends StatelessWidget {
  const CreateNewButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GradientActionButton(
      width: 250,
      height: 60,
      borderRadius: 20,
      gradientColors: const [
        AppColors.listsCardStart,
        AppColors.listsCardEnd,
      ],
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTypography.createNewButton,
      ),
    );
  }
}
