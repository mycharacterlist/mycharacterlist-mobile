import 'package:flutter/material.dart';

class GradientActionButton extends StatelessWidget {
  const GradientActionButton({
    super.key,
    required this.gradientColors,
    required this.onPressed,
    required this.child,
    this.onLongPress,
    this.width,
    this.height,
    this.borderRadius = 25,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.padding,
    this.boxShadow,
  });

  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  static List<BoxShadow> defaultShadow({double opacity = 0.35}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: 20,
        spreadRadius: 1,
        offset: const Offset(0, -8),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: gradientBegin,
            end: gradientEnd,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? defaultShadow(),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: onPressed,
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );
  }
}
