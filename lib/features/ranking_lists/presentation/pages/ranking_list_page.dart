import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/ranking_lists/presentation/views/ranking_list_view.dart';

class RankingListPage extends StatelessWidget {
  const RankingListPage({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(BuildContext context) {
    return RankingListView(listId: listId);
  }
}
