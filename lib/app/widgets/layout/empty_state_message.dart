import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';

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
    final bottomInset = SystemViewPadding.bottomOf(context);

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
