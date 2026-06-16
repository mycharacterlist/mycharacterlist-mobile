import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/viewport_visibility.dart';

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

class _RankingMarqueeTextState extends State<RankingMarqueeText>
    with ParentScrollVisibilityMixin<RankingMarqueeText> {
  static const _startDelay = Duration(milliseconds: 500);

  late final ScrollController _controller;
  int _animationId = 0;
  bool _isInViewport = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateViewportVisibility();
    });
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

  @override
  void onParentScrollVisibilityChanged() {
    _updateViewportVisibility();
  }

  bool get _shouldAnimate => widget.enabled && _isInViewport;

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

    if (!_shouldAnimate) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_shouldAnimate) {
        return;
      }

      _startAnimation();
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

    if (_shouldAnimate) {
      _resetAnimation();
    } else {
      _pauseAnimation();
    }
  }

  Future<void> _startAnimation() async {
    final currentAnimationId = ++_animationId;

    if (!_controller.hasClients || !_shouldAnimate) {
      return;
    }

    final maxScroll = _controller.position.maxScrollExtent;

    if (maxScroll <= 0) {
      if (_isInViewport && _controller.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted ||
              !_shouldAnimate ||
              currentAnimationId != _animationId ||
              !_controller.hasClients) {
            return;
          }

          if (_controller.position.maxScrollExtent <= 0) {
            return;
          }

          _startAnimation();
        });
      }
      return;
    }

    const minSpeed = 20.0;
    const maxSpeed = 80.0;
    final speed = (minSpeed + (maxScroll / 10)).clamp(minSpeed, maxSpeed);
    final durationMs = (maxScroll / speed * 1000).round();

    await Future<void>.delayed(_startDelay);

    if (!mounted ||
        currentAnimationId != _animationId ||
        !_shouldAnimate) {
      return;
    }

    while (mounted && currentAnimationId == _animationId && _shouldAnimate) {
      await _controller.animateTo(
        maxScroll,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted ||
          !_controller.hasClients ||
          currentAnimationId != _animationId ||
          !_shouldAnimate) {
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
          !_shouldAnimate) {
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
