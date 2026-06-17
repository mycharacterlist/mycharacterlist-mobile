import 'package:flutter/material.dart';

abstract final class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    TextAlign textAlign = TextAlign.start,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: textAlign,
        ),
      ),
    );
  }

  static void showCentered(BuildContext context, String message) {
    show(context, message, textAlign: TextAlign.center);
  }
}
