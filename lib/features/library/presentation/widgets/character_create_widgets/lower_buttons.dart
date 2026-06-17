import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';

class LowerButtons extends StatelessWidget {
  const LowerButtons({
    super.key,
    required this.onClear,
    required this.onCreate,
    this.clearLabel = 'Clear all',
    this.createLabel = 'Create',
  });

  final VoidCallback onClear;
  final VoidCallback onCreate;
  final String clearLabel;
  final String createLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 130,
          height: 45,
          child: ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saveBrown,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                clearLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JosefinSlab',
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 130,
          height: 45,
          child: ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cancelGray,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                createLabel,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JosefinSlab',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
