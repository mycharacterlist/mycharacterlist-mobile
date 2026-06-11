import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

class SelectCharacterDialog extends StatefulWidget {
  const SelectCharacterDialog({
    super.key,
    required this.characters,
  });

  final List<Character> characters;

  @override
  State<SelectCharacterDialog> createState() => _SelectCharacterDialogState();
}

class _SelectCharacterDialogState extends State<SelectCharacterDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<Character> _filteredCharacters;
  Character? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    _filteredCharacters = widget.characters;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredCharacters = widget.characters.where((character) {
        if (query.isEmpty) {
          return true;
        }

        return character.name.toLowerCase().contains(query) ||
            character.sourceTitle.toLowerCase().contains(query);
      }).toList();

      if (_selectedCharacter != null &&
          !_filteredCharacters.any((character) => character.id == _selectedCharacter!.id)) {
        _selectedCharacter = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add character'),
      content: SizedBox(
        width: 350,
        height: 400,
        child: Column(
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
                  itemCount: _filteredCharacters.length,
                  itemBuilder: (context, index) {
                    final character = _filteredCharacters[index];
                    final isSelected = _selectedCharacter?.id == character.id;

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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedCharacter == null
              ? null
              : () => Navigator.pop(context, _selectedCharacter),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
