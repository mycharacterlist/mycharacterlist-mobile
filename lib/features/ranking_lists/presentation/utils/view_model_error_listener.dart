import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void listenViewModelError(
  WidgetRef ref, {
  required ProviderListenable<dynamic> provider,
  required String? Function(dynamic state) selectError,
  required VoidCallback clearError,
  required BuildContext context,
}) {
  ref.listen(provider, (previous, next) {
    final errorMessage = selectError(next);
    final previousError = previous == null ? null : selectError(previous);

    if (errorMessage == null || previousError == errorMessage) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );

    clearError();
  });
}
