import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/theme/app_typography.dart';

/// Blocks interaction and shows a loading indicator with optional progress text.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    this.title,
    this.completed,
    this.total,
    this.dimmed = true,
    this.indicatorColor = Colors.white,
  });

  final String? title;
  final int? completed;
  final int? total;
  final bool dimmed;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: dimmed
              ? Colors.black.withValues(alpha: 0.72)
              : Colors.transparent,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: indicatorColor),
                if (title != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: AppTypography.loadingOverlayTitle,
                  ),
                ],
                if (completed != null && total != null && total! > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$completed / $total',
                    style: AppTypography.loadingOverlayProgress,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
