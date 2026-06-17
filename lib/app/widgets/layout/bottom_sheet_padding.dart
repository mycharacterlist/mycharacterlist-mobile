import 'package:flutter/material.dart';

/// Keeps a fixed bottom margin above the system navigation bar in sheets.
class BottomSheetPadding extends StatelessWidget {
  const BottomSheetPadding({
    super.key,
    required this.child,
    this.bottomMargin = 0,
  });

  final Widget child;
  final double bottomMargin;

  static double bottomInset(
    BuildContext context, {
    double margin = 0,
  }) {
    return margin + MediaQuery.viewPaddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset(context, margin: bottomMargin),
      ),
      child: child,
    );
  }
}
