import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final Icon icon;

  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const PlusButton({
    super.key,

    required this.icon,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009768), Color(0xFF003122)],

          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),

            blurRadius: 20,
            spreadRadius: 1,

            offset: const Offset(0, -8),
          ),
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        onPressed: onPressed,
        onLongPress: onLongPress,

        child: icon,
      ),
    );
  }
}