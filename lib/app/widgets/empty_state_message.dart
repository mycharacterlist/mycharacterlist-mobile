import 'package:flutter/material.dart';

const emptyStateTextStyle = TextStyle(
  fontSize: 24,
  color: Colors.white,
);

class EmptyStateMessage extends StatelessWidget {
  const EmptyStateMessage({
    super.key,
    required this.message,
    this.bottomPadding = 84,
    this.color = Colors.white,
  });

  final String message;
  final double bottomPadding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + bottomInset),
      child: Center(
        child: Text(
          message,
          style: emptyStateTextStyle.copyWith(color: color),
        ),
      ),
    );
  }
}
