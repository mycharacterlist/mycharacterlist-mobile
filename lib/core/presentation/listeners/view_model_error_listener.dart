import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';

void listenViewModelError(
  WidgetRef ref, {
  required ProviderListenable<dynamic> provider,
  required String? Function(dynamic state) selectError,
  required BuildContext context,
  VoidCallback? clearError,
  bool centered = false,
}) {
  ref.listen(provider, (previous, next) {
    final errorMessage = selectError(next);
    final previousError = previous == null ? null : selectError(previous);

    if (errorMessage == null || previousError == errorMessage) {
      return;
    }

    if (centered) {
      AppSnackBar.showCentered(context, errorMessage);
    } else {
      AppSnackBar.show(context, errorMessage);
    }

    clearError?.call();
  });
}
