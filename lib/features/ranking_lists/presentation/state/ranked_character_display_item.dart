class RankedCharacterDisplayItem {
  const RankedCharacterDisplayItem({
    required this.id,
    required this.characterId,
    required this.position,
    required this.title,
    required this.subtitle,
    this.isCharacterAvailable = true,
  });

  final String id;
  final String characterId;
  final int position;
  final String title;
  final String subtitle;
  final bool isCharacterAvailable;
}
