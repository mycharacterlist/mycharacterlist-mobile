import 'package:flutter/material.dart';

class SavePatchDialog extends StatefulWidget {
  const SavePatchDialog({
    super.key,
    required this.suggestedLabel,
  });

  final String suggestedLabel;

  static Future<String?> show(
    BuildContext context, {
    required String suggestedLabel,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => SavePatchDialog(suggestedLabel: suggestedLabel),
    );
  }

  @override
  State<SavePatchDialog> createState() => _SavePatchDialogState();
}

class _SavePatchDialogState extends State<SavePatchDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.suggestedLabel);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _controller.text.trim();
    if (label.isEmpty) {
      setState(() {
        _errorText = 'Enter a patch name';
      });
      return;
    }

    Navigator.pop(context, label);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save patch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Name this snapshot of the current ranking.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Patch name',
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
