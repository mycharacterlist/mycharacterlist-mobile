import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Back to menu'),
            ),
          ],
        ),
      ),
    );
  }
}
