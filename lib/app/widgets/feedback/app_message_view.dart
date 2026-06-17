import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_typography.dart';

/// Centered inline message for panels, dialogs, and async placeholders.
class AppMessageView extends StatelessWidget {
  const AppMessageView({
    super.key,
    required this.message,
    this.textAlign = TextAlign.center,
    this.style,
  });

  final String message;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: textAlign,
        style: style ?? AppTypography.inlineMessage,
      ),
    );
  }
}
