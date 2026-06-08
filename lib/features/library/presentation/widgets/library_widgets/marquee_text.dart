import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({super.key, required this.text, required this.style});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController controller;
  int animationId = 0;

  @override
  void initState() {
    super.initState();

    controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startAnimation();
    });
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      animationId++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !controller.hasClients) {
          return;
        }

        controller.jumpTo(0);
        startAnimation();
      });
    }
  }

  void startAnimation() async {
    final currentAnimationId = ++animationId;

    if (!controller.hasClients) {
      return;
    }

    final maxScroll = controller.position.maxScrollExtent;

    if (maxScroll <= 0) {
      return;
    }

    const double minSpeed = 20;

    const double maxSpeed = 80;

    double speed = minSpeed + (maxScroll / 10);

    if (speed > maxSpeed) {
      speed = maxSpeed;
    }

    final durationMs = (maxScroll / speed * 1000).round();

    while (mounted && currentAnimationId == animationId) {
      await controller.animateTo(
        controller.position.maxScrollExtent,

        duration: Duration(milliseconds: durationMs),

        curve: Curves.linear,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted || currentAnimationId != animationId) {
        return;
      }

      await controller.animateTo(
        0,

        duration: Duration(milliseconds: durationMs),

        curve: Curves.linear,
      );

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    animationId++;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,

      scrollDirection: Axis.horizontal,

      physics: const NeverScrollableScrollPhysics(),

      child: Text(widget.text, softWrap: false, style: widget.style),
    );
  }
}
