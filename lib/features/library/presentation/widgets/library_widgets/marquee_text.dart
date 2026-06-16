import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/viewport_visibility.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({super.key, required this.text, required this.style});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with ParentScrollVisibilityMixin<MarqueeText> {
  static const _startDelay = Duration(milliseconds: 500);

  late ScrollController controller;
  int animationId = 0;
  bool _isInViewport = false;

  @override
  void initState() {
    super.initState();

    controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewportVisibility();
    });
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _resetAnimation();
    }
  }

  @override
  void onParentScrollVisibilityChanged() {
    _updateViewportVisibility();
  }

  void _pauseAnimation() {
    animationId++;

    if (controller.hasClients) {
      controller.jumpTo(0);
    }
  }

  void _resetAnimation() {
    animationId++;

    if (controller.hasClients) {
      controller.jumpTo(0);
    }

    if (!_isInViewport) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isInViewport) {
        return;
      }

      startAnimation();
    });
  }

  void _updateViewportVisibility() {
    if (!mounted) {
      return;
    }

    final visible = isWidgetVisibleInViewport(context);
    if (visible == _isInViewport) {
      return;
    }

    _isInViewport = visible;

    if (visible) {
      _resetAnimation();
    } else {
      _pauseAnimation();
    }
  }

  void startAnimation() async {
    final currentAnimationId = ++animationId;

    if (!_isInViewport || !controller.hasClients) {
      return;
    }

    final maxScroll = controller.position.maxScrollExtent;

    if (maxScroll <= 0) {
      if (_isInViewport && controller.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              !_isInViewport ||
              currentAnimationId != animationId ||
              !controller.hasClients) {
            return;
          }

          if (controller.position.maxScrollExtent <= 0) {
            return;
          }

          startAnimation();
        });
      }
      return;
    }

    const double minSpeed = 20;
    const double maxSpeed = 80;
    double speed = minSpeed + (maxScroll / 10);

    if (speed > maxSpeed) {
      speed = maxSpeed;
    }

    final durationMs = (maxScroll / speed * 1000).round();

    await Future<void>.delayed(_startDelay);

    if (!mounted ||
        currentAnimationId != animationId ||
        !_isInViewport) {
      return;
    }

    while (mounted && currentAnimationId == animationId && _isInViewport) {
      await controller.animateTo(
        maxScroll,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted ||
          currentAnimationId != animationId ||
          !_isInViewport) {
        return;
      }

      await controller.animateTo(
        0,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted ||
          currentAnimationId != animationId ||
          !_isInViewport) {
        return;
      }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        final fits = textPainter.width <= constraints.maxWidth;

        if (fits) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              maxLines: 1,
              softWrap: false,
              style: widget.style,
            ),
          );
        }

        return SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Text(widget.text, softWrap: false, style: widget.style),
        );
      },
    );
  }
}
