import 'package:flutter/material.dart';

class LowerButtons extends StatelessWidget {
  const LowerButtons({
    super.key,
    required this.onClear,
    required this.onCreate,
    this.isClearLoading = false,
    this.isCreateLoading = false,
    this.clearLabel = 'Clear all',
    this.createLabel = 'Create',
    this.clearLoadingLabel = 'Clearing...',
    this.createLoadingLabel = 'Saving...',
  });

  final VoidCallback onClear;
  final VoidCallback onCreate;
  final bool isClearLoading;
  final bool isCreateLoading;
  final String clearLabel;
  final String createLabel;
  final String clearLoadingLabel;
  final String createLoadingLabel;

  @override
  Widget build(BuildContext context) {
    final isBusy = isClearLoading || isCreateLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        SizedBox(
          width: 130,
          height: 45,

          child: ElevatedButton(
            onPressed: isBusy ? null : onClear,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E2E00),
              foregroundColor: Colors.white,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isClearLoading ? clearLoadingLabel : clearLabel,
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
            onPressed: isBusy ? null : onCreate,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF444444),

              foregroundColor: Colors.white,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isCreateLoading ? createLoadingLabel : createLabel,
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
