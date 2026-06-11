import 'package:flutter/material.dart';

class RankingMarqueeText extends StatefulWidget {
  const RankingMarqueeText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
  }

  @override
  void didUpdateWidget(covariant RankingMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _animationId++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_controller.hasClients) {
          return;
        }

        _controller.jumpTo(0);
        _startAnimation();
      });
    }
  }

  Future<void> _startAnimation() async {
    final currentAnimationId = ++_animationId;

    if (!_controller.hasClients) {
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

    while (mounted && currentAnimationId == _animationId) {
      await _controller.animateTo(
        maxScroll,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted || !_controller.hasClients || currentAnimationId != _animationId) {
        return;
      }

      await _controller.animateTo(
        0,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.linear,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted || !_controller.hasClients || currentAnimationId != _animationId) {
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
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.text,
          softWrap: false,
          strutStyle: const StrutStyle(forceStrutHeight: false),
          style: widget.style,
        ),
      ),
    );
  }
}
