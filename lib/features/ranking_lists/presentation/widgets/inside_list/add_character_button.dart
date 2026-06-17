import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class AddCharacterButton extends StatelessWidget {
  const AddCharacterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.addCharacterGradientStart,
            AppColors.addCharacterGradientEnd,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.add,
        size: 50,
        color: Colors.blueAccent,
      ),
    );
  }
}
