import 'package:flutter/material.dart';

/// Pins a bottom action with a fixed margin above the system navigation bar.
class BottomActionSlot extends StatelessWidget {
  const BottomActionSlot({
    super.key,
    required this.child,
    this.bottomMargin = 20,
  });

  final Widget child;
  final double bottomMargin;

  @override
  Widget build(BuildContext context) {
    // viewPadding is not consumed by Scaffold, unlike padding.
    final systemBottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomMargin + systemBottomInset,
      child: Center(child: child),
    );
  }
}
