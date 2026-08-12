import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/presentation/utils/patch_formatters.dart';

class EditPatchResult {
  const EditPatchResult({
    required this.label,
    required this.releaseDate,
  });

  final String label;
  final String releaseDate;
}

class EditPatchDialog extends StatefulWidget {
  const EditPatchDialog({
    super.key,
    required this.patch,
  });

  final RankingListPatch patch;

  static Future<EditPatchResult?> show(
    BuildContext context, {
    required RankingListPatch patch,
  }) {
    return showDialog<EditPatchResult>(
      context: context,
      builder: (_) => EditPatchDialog(patch: patch),
    );
  }

  @override
  State<EditPatchDialog> createState() => _EditPatchDialogState();
}

class _EditPatchDialogState extends State<EditPatchDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _releaseDateController;
  late DateTime _selectedReleaseDate;
  String? _labelErrorText;

  @override
  void initState() {
    super.initState();
    _selectedReleaseDate = widget.patch.createdAt;
    _labelController = TextEditingController(text: widget.patch.label);
    _releaseDateController = TextEditingController(
      text: PatchFormatters.formatReleaseDate(_selectedReleaseDate),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _labelController.text.trim();

    setState(() {
      _labelErrorText = label.isEmpty ? 'Enter patch name' : null;
    });

    if (_labelErrorText != null) {
      return;
    }

    Navigator.pop(
      context,
      EditPatchResult(
        label: label,
        releaseDate: PatchFormatters.formatReleaseDate(_selectedReleaseDate),
      ),
    );
  }

  Future<void> _pickReleaseDate() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReleaseDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedReleaseDate = pickedDate;
      _releaseDateController.text =
          PatchFormatters.formatReleaseDate(_selectedReleaseDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit patch'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Version',
              errorText: _labelErrorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _releaseDateController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Release date',
              hintText: '23.06.2026',
              suffixIcon: Icon(Icons.calendar_month_outlined),
            ),
            onTap: _pickReleaseDate,
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
