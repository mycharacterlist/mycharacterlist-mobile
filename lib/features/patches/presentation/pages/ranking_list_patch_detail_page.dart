import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankingListPatchDetailPage extends ConsumerWidget {
  const RankingListPatchDetailPage({
    super.key,
    required this.listId,
    required this.patchId,
  });

  final String listId;
  final String patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patch detail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Patch detail',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
