import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class FilterButton
    extends StatelessWidget {

  final VoidCallback onPressed;

  const FilterButton({
    super.key,

    required this.onPressed,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Container(
      width: 60,
      height: 60,

      decoration:
      BoxDecoration(
        color: AppColors.searchField,

        borderRadius: BorderRadius.circular(20,),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25,),
            blurRadius: 12,
            offset: const Offset(0, 5,),
          ),
        ],
      ),

      child: IconButton(
        onPressed: onPressed,

        icon: const Icon(
          Icons.tune,
          size: 38,
          color: Colors.black87,
        ),
      ),
    );
  }
}