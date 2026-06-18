import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class PatchActionButton extends StatelessWidget {
  const PatchActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: const Center(
        child: Text(
          'Patch',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Joan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
