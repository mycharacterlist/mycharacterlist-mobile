import 'package:flutter/material.dart';

class CompareStatRow extends StatelessWidget {
  const CompareStatRow({
    super.key,
    required this.leftValue,
    required this.title,
    required this.rightValue,
    this.leftColor = Colors.white,
    this.rightColor = Colors.white,
    this.leftFontSize = 28,
    this.rightFontSize = 28,
  });

  final String leftValue;
  final String title;
  final String rightValue;

  final Color leftColor;
  final Color rightColor;

  final double leftFontSize;
  final double rightFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            leftValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: leftFontSize,
              color: leftColor,
              fontFamily: 'Itim',
            ),
          ),
        ),

        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontFamily: 'ImFellEnglishSC',
            ),
          ),
        ),

        Expanded(
          child: Text(
            rightValue,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rightFontSize,
              color: rightColor,
              fontFamily: 'Itim',
            ),
          ),
        ),
      ],
    );
  }
}