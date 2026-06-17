import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/app/widgets/text/marquee_text.dart';

class LibraryCard extends StatelessWidget {
  final String mainText;
  final String sideText;
  final int index;

  final VoidCallback onPressed;
  final VoidCallback onEditPressed;

  const LibraryCard({
    super.key,

    required this.mainText,
    required this.sideText,
    required this.index,

    required this.onPressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

      height: 100,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.libraryGreenDark, AppColors.libraryGreen],
        ),

        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),

            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

        onPressed: onPressed,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 60),

                padding: const EdgeInsets.symmetric(horizontal: 10),

                height: 90,

                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Center(
                  child: Text(
                    '${index + 1}.',

                    style: const TextStyle(
                      fontSize: 34,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      fontFamily: 'JosefinSlab',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  mainAxisAlignment: MainAxisAlignment.center,

                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Flexible(
                      child: SizedBox(
                        height: 38,

                        child: MarqueeText(
                          key: ValueKey('main_$mainText'),
                          text: mainText,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            height: 1.1,
                            fontFamily: 'JosefinSlab',
                          ),
                        ),
                      ),
                    ),

                    Flexible(
                      child: SizedBox(
                        height: 30,

                        child: MarqueeText(
                          key: ValueKey('side_$sideText'),
                          text: sideText,

                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            height: 1.1,
                            fontFamily: 'JosefinSlab',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onEditPressed,

                icon: const Icon(
                  Icons.edit_square,
                  color: Colors.black,
                  size: 42,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
