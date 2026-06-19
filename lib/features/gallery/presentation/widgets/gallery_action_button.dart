import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class GalleryActionButton extends StatelessWidget {
  const GalleryActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.characterAppBarBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Joan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
