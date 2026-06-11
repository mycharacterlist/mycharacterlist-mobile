import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_character_display_item.dart';

class RankedListContent {
  const RankedListContent({
    this.isLoadingCharacters = false,
    this.isLoadingLibrary = false,
    this.libraryFailed = false,
    this.isEmpty = false,
    this.items = const [],
  });

  final bool isLoadingCharacters;
  final bool isLoadingLibrary;
  final bool libraryFailed;
  final bool isEmpty;
  final List<RankedCharacterDisplayItem> items;
}
