import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class SelectCharacterDialog extends ConsumerStatefulWidget {
  const SelectCharacterDialog({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  ConsumerState<SelectCharacterDialog> createState() => _SelectCharacterDialogState();
}

class _SelectCharacterDialogState extends ConsumerState<SelectCharacterDialog> {
  final TextEditingController _searchController = TextEditingController();
  Character? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Character> _filterCharacters(List<Character> characters) {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      return characters;
    }

    return characters.where((character) {
      return character.name.toLowerCase().contains(query) ||
          character.sourceTitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(libraryCharactersProvider);
    final rankedCharacterIds = ref.watch(
      rankingCharactersViewModelProvider(widget.listId).select(
        (state) => state.characters
            .map((rankedCharacter) => rankedCharacter.characterId)
            .toSet(),
      ),
    );

    return AlertDialog(
      title: const Text('Add character'),
      content: SizedBox(
        width: 350,
        height: 400,
        child: libraryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Failed to load characters'),
          ),
          data: (libraryCharacters) {
            if (libraryCharacters.isEmpty) {
              return const Center(child: Text('Library is empty'));
            }

            final availableCharacters = libraryCharacters
                .where((character) => !rankedCharacterIds.contains(character.id))
                .toList();

            if (availableCharacters.isEmpty) {
              return const Center(
                child: Text('All library characters are already in this list'),
              );
            }

            final filteredCharacters = _filterCharacters(availableCharacters);
            final selectedCharacter = _selectedCharacter != null &&
                    filteredCharacters.any(
                      (character) => character.id == _selectedCharacter!.id,
                    )
                ? _selectedCharacter
                : null;

            return Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Character name',
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredCharacters.length,
                      itemBuilder: (context, index) {
                        final character = filteredCharacters[index];
                        final isSelected = selectedCharacter?.id == character.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.25)
                                  : Colors.transparent,
                              child: ListTile(
                                title: Text(character.name),
                                subtitle: Text(character.sourceTitle),
                                onTap: () {
                                  setState(() => _selectedCharacter = character);
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        libraryAsync.maybeWhen(
          data: (libraryCharacters) {
            final availableCharacters = libraryCharacters
                .where((character) => !rankedCharacterIds.contains(character.id))
                .toList();

            if (availableCharacters.isEmpty) {
              return const SizedBox.shrink();
            }

            final filteredCharacters = _filterCharacters(availableCharacters);
            final selectedCharacter = _selectedCharacter != null &&
                    filteredCharacters.any(
                      (character) => character.id == _selectedCharacter!.id,
                    )
                ? _selectedCharacter
                : null;

            return ElevatedButton(
              onPressed: selectedCharacter == null
                  ? null
                  : () => Navigator.pop(context, selectedCharacter),
              child: const Text('Add'),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
