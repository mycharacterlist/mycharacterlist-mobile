import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_marquee_text.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_position_field.dart';

class RankingCharacterCard extends StatelessWidget {
  const RankingCharacterCard({
    super.key,
    required this.itemId,
    required this.index,
    required this.title,
    required this.subtitle,
    this.dragHandle,
    this.isEditMode = false,
    this.animateMarquee = true,
    this.isDragProxy = false,
    this.maxPosition,
    this.onPositionSubmitted,
  });

  final String itemId;
  final int index;
  final String title;
  final String subtitle;
  final Widget? dragHandle;
  final bool isEditMode;
  final bool animateMarquee;
  final bool isDragProxy;
  final int? maxPosition;
  final ValueChanged<int>? onPositionSubmitted;

  Color _getBadgeColor() {
    switch (index) {
      case 1:
        return const Color(0xFFE6E600);
      case 2:
        return const Color(0xFF898985);
      case 3:
        return const Color(0xFF935712);
      default:
        return const Color(0xFF9996DF);
    }
  }

  LinearGradient _getCardGradient() {
    switch (index) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFFFD6C), Color(0xFFD9D9D9)],
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF979794), Color(0xFFD9D9D9)],
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF9B4D22), Color(0xFFD9D9D9)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFC8C3FA), Color(0xFFD9D9D9)],
        );
    }
  }

  LinearGradient _getTitleGradient() {
    switch (index) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFFFF8001), Color(0xFFCAC300)],
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF4D4B49), Color(0xFF979794)],
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF3C2207), Color(0xFFEBA5A5)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF3424EE)],
        );
    }
  }

  Widget _buildTitleText() {
    const style = TextStyle(
      fontSize: 40,
      fontFamily: 'Joan',
      color: Colors.white,
    );

    if (!animateMarquee) {
      return _StaticClippedText(
        text: title,
        style: style,
        gradient: _getTitleGradient(),
      );
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => _getTitleGradient().createShader(bounds),
      child: RankingMarqueeText(
        key: ValueKey('title-$itemId'),
        listPosition: index,
        text: title,
        style: style,
      ),
    );
  }

  Widget _buildSubtitleText() {
    const style = TextStyle(
      fontSize: 24,
      color: Colors.black,
      fontFamily: 'Joan',
    );

    if (!animateMarquee) {
      return _StaticClippedText(text: subtitle, style: style);
    }

    return RankingMarqueeText(
      key: ValueKey('subtitle-$itemId'),
      listPosition: index,
      text: subtitle,
      style: style,
    );
  }

  Widget _buildPositionBadge() {
    if (isDragProxy || !isEditMode) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '#$index',
          maxLines: 1,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'JosefinSans',
          ),
        ),
      );
    }

    if (maxPosition != null && onPositionSubmitted != null) {
      return RankingPositionField(
        key: ValueKey('position-$itemId'),
        position: index,
        maxPosition: maxPosition!,
        onSubmitted: onPositionSubmitted!,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 115,
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _getBadgeColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Center(child: _buildPositionBadge()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 55, child: _buildTitleText()),
                SizedBox(height: 35, child: _buildSubtitleText()),
              ],
            ),
          ),
          if (dragHandle != null) dragHandle!,
          const SizedBox(width: 8),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RepaintBoundary(
        child: Material(
          color: Colors.transparent,
          child: isEditMode ? card : InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {},
            child: card,
          ),
        ),
      ),
    );
  }
}

class _StaticClippedText extends StatelessWidget {
  const _StaticClippedText({
    required this.text,
    required this.style,
    this.gradient,
  });

  final String text;
  final TextStyle style;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final label = Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.clip,
        softWrap: false,
        style: style,
      ),
    );

    if (gradient == null) {
      return ClipRect(child: label);
    }

    return ClipRect(
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => gradient!.createShader(bounds),
        child: label,
      ),
    );
  }
}
