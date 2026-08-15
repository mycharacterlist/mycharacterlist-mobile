import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.color,
    this.centered = true,
  });

  final Color? color;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(color: color);

    if (!centered) {
      return indicator;
    }

    return Center(child: indicator);
  }
}
