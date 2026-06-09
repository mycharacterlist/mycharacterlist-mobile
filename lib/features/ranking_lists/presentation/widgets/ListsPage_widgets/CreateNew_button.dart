import 'package:flutter/material.dart';

class CreateNewButton extends StatelessWidget {

  final String text;

  final VoidCallback onPressed;

  const CreateNewButton({
    super.key,

    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 60,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3D4789),
            Color(0xFF2F013B),
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        ),

        onPressed: onPressed,

        child: Text(
          text,

          style: const TextStyle(
            color: Color(0xFFBEB53E),

            fontFamily: 'JPAnimeFont',

            fontSize: 30,
          ),
        ),
      ),
    );
  }
}