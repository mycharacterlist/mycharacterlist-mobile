import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

class CharacterSectionPanel extends StatelessWidget {
  const CharacterSectionPanel({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(
        color: AppColors.sectionPanel,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.characterSectionTitle,
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
