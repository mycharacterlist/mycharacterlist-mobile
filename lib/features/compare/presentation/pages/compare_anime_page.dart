import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompareAnimePage extends ConsumerWidget {
  const CompareAnimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare page'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Compare by anime',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
