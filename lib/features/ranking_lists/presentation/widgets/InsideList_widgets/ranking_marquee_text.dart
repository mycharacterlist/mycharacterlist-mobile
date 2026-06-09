import 'package:flutter/material.dart';

class RankingMarqueeText extends StatefulWidget {

  final String text;

  final TextStyle style;

  const RankingMarqueeText({
    super.key,

    required this.text,
    required this.style,
  });

  @override
  State<RankingMarqueeText>
  createState() =>
      _RankingMarqueeTextState();
}

class _RankingMarqueeTextState extends State<RankingMarqueeText> {

  late ScrollController controller;

  @override
  void initState() {

    super.initState();

    controller = ScrollController();

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {

        startAnimation();
      },
    );
  }

  void startAnimation() async {

    if (!controller.hasClients)
    {
      return;
    }

    final maxScroll = controller.position.maxScrollExtent;

    if (maxScroll <= 0)
    {
      return;
    }

    const double minSpeed = 20;

    const double maxSpeed = 80;

    double speed = minSpeed + (maxScroll / 10);

    if (speed > maxSpeed)
    {
      speed = maxSpeed;
    }

    final durationMs =
    (maxScroll / speed * 1000).round();

    while (mounted) {

      await controller.animateTo(
        maxScroll,

        duration:
        Duration(
          milliseconds: durationMs,
        ),
        curve: Curves.linear,
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      await controller.animateTo(
        0,

        duration:
        Duration(
          milliseconds: durationMs,
        ),
        curve: Curves.linear,
      );

      await Future.delayed(
        const Duration(
            milliseconds: 500
        ),
      );
    }
  }

  @override
  void dispose() {

    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return SingleChildScrollView(
      controller: controller,

      scrollDirection: Axis.horizontal,

      physics: const NeverScrollableScrollPhysics(),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Text(
          widget.text,
          softWrap: false,
          strutStyle: const StrutStyle(
            forceStrutHeight: false,
          ),

          style: widget.style,
        ),
      ),
    );
  }
}