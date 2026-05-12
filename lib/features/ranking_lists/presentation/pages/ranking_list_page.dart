import 'package:flutter/material.dart';

class RankingListPage extends StatelessWidget {
  const RankingListPage({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking list')),
      body: const Center(child: Text('Ranking list page')),
    );
  }
}
