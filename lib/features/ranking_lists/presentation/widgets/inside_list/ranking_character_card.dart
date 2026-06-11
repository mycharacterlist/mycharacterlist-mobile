import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_marquee_text.dart';

class RankingCharacterCard extends StatelessWidget {
  const RankingCharacterCard({
    super.key,
    required this.index,
    required this.title,
    required this.subtitle,
    this.dragHandle,
  });

  final int index;
  final String title;
  final String subtitle;
  final Widget? dragHandle;

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {},
          child: Container(
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
                  child: Center(
                    child: FittedBox(
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
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 55,
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            switch (index) {
                              case 1:
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8001),
                                    Color(0xFFCAC300),
                                  ],
                                ).createShader(bounds);
                              case 2:
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF4D4B49),
                                    Color(0xFF979794),
                                  ],
                                ).createShader(bounds);
                              case 3:
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF3C2207),
                                    Color(0xFFEBA5A5),
                                  ],
                                ).createShader(bounds);
                              default:
                                return const LinearGradient(
                                  colors: [
                                    Color(0xFF000000),
                                    Color(0xFF3424EE),
                                  ],
                                ).createShader(bounds);
                            }
                          },
                          child: RankingMarqueeText(
                            text: title,
                            style: const TextStyle(
                              fontSize: 40,
                              fontFamily: 'Joan',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: RankingMarqueeText(
                          text: subtitle,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                            fontFamily: 'Joan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (dragHandle != null) dragHandle!,
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
