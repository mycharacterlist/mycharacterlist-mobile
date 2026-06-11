import 'package:flutter/material.dart';

class RankingMarqueeText extends StatefulWidget {
  const RankingMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.listPosition,
    this.enabled = true,
  });

  final String text;
  final TextStyle style;
  final int? listPosition;
  final bool enabled;

  @override
  State<RankingMarqueeText> createState() => _RankingMarqueeTextState();
}

class _RankingMarqueeTextState extends State<RankingMarqueeText> {
  late final ScrollController _controller;
  int _animationId = 0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resetAnimation());
  }

  @override
  void didUpdateWidget(covariant RankingMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldReset = oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.listPosition != widget.listPosition ||
        (!oldWidget.enabled && widget.enabled);

    if (shouldReset) {
      _resetAnimation();
      return;
    }

    if (oldWidget.enabled && !widget.enabled) {
      _pauseAnimation();
    }
  }

  void _pauseAnimation() {
    _animationId++;

    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }
  }

  void _resetAnimation() {
    _animationId++;

    if (_controller.hasClients) {
      _controller.jumpTo(0);
    }

    if (!widget.enabled) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) {
        return;
      }

      _startAnimation();
    });
  }

  Future<void> _startAnimation() async {
    final currentAnimationId = ++_animationId;

    if (!_controller.hasClients || !widget.enabled) {
      return;
    }

    final maxScroll = _controller.position.maxScrollExtent;

    if (maxScroll <= 0) {
      return;
    }

    const minSpeed = 20.0;
    const maxSpeed = 80.0;
    final speed = (minSpeed + (maxScroll / 10)).clamp(minSpeed, maxSpeed);
    final durationMs = (maxScroll / speed * 1000).round();

    while (mounted && currentAnimationId == _animationId && widget.enabled) {
      await _controller.animateTo(
        maxScroll,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted ||
          !_controller.hasClients ||
          currentAnimationId != _animationId ||
          !widget.enabled) {
        return;
      }

      await _controller.animateTo(
        0,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted ||
          !_controller.hasClients ||
          currentAnimationId != _animationId ||
          !widget.enabled) {
        return;
      }
    }
  }

  @override
  void dispose() {
    _animationId++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
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
            controller: _controller,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            child: Text(
              widget.text,
              softWrap: false,
              style: widget.style,
            ),
          );
        },
      ),
    );
  }
}
