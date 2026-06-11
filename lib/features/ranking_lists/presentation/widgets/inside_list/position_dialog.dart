import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

class PositionDialog extends StatefulWidget {
  const PositionDialog({
    super.key,
    required this.character,
    required this.maxPosition,
  });

  final Character character;
  final int maxPosition;

  @override
  State<PositionDialog> createState() => _PositionDialogState();
}

class _PositionDialogState extends State<PositionDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.maxPosition.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final position = int.tryParse(_controller.text);

    if (position == null || position < 1 || position > widget.maxPosition) {
      setState(() {
        _errorText = 'Enter a position from 1 to ${widget.maxPosition}';
      });
      return;
    }

    Navigator.pop(context, position);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add character'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.character.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(widget.character.sourceTitle),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Position',
              errorText: _errorText,
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
