import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';

/// Pins a bottom action with a fixed margin above the system navigation bar.
class BottomActionSlot extends StatelessWidget {
  const BottomActionSlot({
    super.key,
    required this.child,
    this.bottomMargin = 20,
  });

  final Widget child;
  final double bottomMargin;

  static const double defaultButtonHeight = 60;

  /// List/sheet bottom padding: margin + button + equal margin above the button.
  static double contentBottomPadding(
    BuildContext context, {
    double bottomMargin = 20,
    double buttonHeight = defaultButtonHeight,
    double? topMargin,
  }) {
    final clearanceAbove = topMargin ?? bottomMargin;

    return bottomMargin +
        buttonHeight +
        clearanceAbove +
        SystemViewPadding.bottomOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final systemBottomInset = SystemViewPadding.bottomOf(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomMargin + systemBottomInset,
      child: Center(child: child),
    );
  }
}
