import 'package:flutter/material.dart';

class LowerButtons extends StatelessWidget {
  const LowerButtons({
    super.key,
    required this.onClear,
    required this.onCreate,
    this.isSaving = false,
  });

  final VoidCallback onClear;
  final VoidCallback onCreate;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        SizedBox(
          width: 130,
          height: 45,

          child: ElevatedButton(
            onPressed: isSaving ? null : onClear,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E2E00),
              foregroundColor: Colors.white,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: const Text(
              'Clear all',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),
        ),

        SizedBox(
          width: 130,
          height: 45,

          child: ElevatedButton(
            onPressed: isSaving ? null : onCreate,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF444444),

              foregroundColor: Colors.white,
              elevation: 4,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),

            child: Text(
              isSaving ? 'Saving...' : 'Create',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'JosefinSlab',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
