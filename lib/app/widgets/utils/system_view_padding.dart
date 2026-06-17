import 'package:flutter/widgets.dart';

/// OS-level view padding that stays stable while the keyboard opens/closes.
class SystemViewPadding {
  SystemViewPadding._();

  static EdgeInsets of(BuildContext context) {
    final view = View.of(context);
    return EdgeInsets.fromViewPadding(view.viewPadding, view.devicePixelRatio);
  }

  static double bottomOf(BuildContext context) => of(context).bottom;
}
