import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final String text;

  final Color firstColor;
  final Color secondColor;

  final VoidCallback onPressed;

  const HomeButton({
    super.key,
    required this.text,
    required this.firstColor,
    required this.secondColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              firstColor,
              secondColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(25),
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
              fontSize: 40,
              color: Colors.black,
              fontFamily: 'LibreCaslonText',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}