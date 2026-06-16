import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateListDialog {
  static void show({
    required BuildContext context,
    required TextEditingController controller,
    required Future<void> Function(Color) onCreate,
    Color initialColor = const Color(0xFF768AFD),
    String title = 'Create list',
    String submitLabel = 'Create',
    Future<void> Function()? onDelete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return _CreateListDialog(
          controller: controller,
          onCreate: onCreate,
          initialColor: initialColor,
          title: title,
          submitLabel: submitLabel,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _CreateListDialog extends StatefulWidget {
  const _CreateListDialog({
    required this.controller,
    required this.onCreate,
    required this.initialColor,
    required this.title,
    required this.submitLabel,
    this.onDelete,
  });

  final TextEditingController controller;
  final Future<void> Function(Color) onCreate;
  final Color initialColor;
  final String title;
  final String submitLabel;
  final Future<void> Function()? onDelete;

  @override
  State<_CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<_CreateListDialog> {
  late Color _selectedColor;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return Dialog(
      insetAnimationDuration: Duration.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.title, style: titleStyle),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: widget.controller,
                        onChanged: (_) {
                          if (_nameErrorText != null) {
                            setState(() => _nameErrorText = null);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter list name',
                          errorText: _nameErrorText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Choose color'),
                      ),
                      const SizedBox(height: 10),
                      _ColorPickerSection(
                        initialColor: _selectedColor,
                        onColorChanged: (color) => _selectedColor = color,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OverflowBar(
                alignment: MainAxisAlignment.end,
                spacing: 8,
                children: [
                  if (widget.onDelete != null)
                    TextButton(
                      onPressed: widget.onDelete,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  TextButton(
                    onPressed: () {
                      widget.controller.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (widget.controller.text.trim().isEmpty) {
                        setState(() => _nameErrorText = 'Enter list name');
                        return;
                      }

                      await widget.onCreate(_selectedColor);
                    },
                    child: Text(widget.submitLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPickerSection extends StatefulWidget {
  const _ColorPickerSection({
    required this.initialColor,
    required this.onColorChanged,
  });

  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_ColorPickerSection> createState() => _ColorPickerSectionState();
}

class _ColorPickerSectionState extends State<_ColorPickerSection> {
  late Color _selectedColor;
  double? _lockedScreenHeight;

  static const _targetPickerFraction = 0.8;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    _lockedScreenHeight ??= screenHeight;

    final targetPickerHeight = _lockedScreenHeight! * _targetPickerFraction;
    final pickerAreaHeightPercent =
        (targetPickerHeight / screenHeight).clamp(0.0, 1.0);

    return ColorPicker(
      pickerColor: _selectedColor,
      onColorChanged: (color) {
        setState(() => _selectedColor = color);
        widget.onColorChanged(color);
      },
      enableAlpha: false,
      displayThumbColor: true,
      portraitOnly: true,
      labelTypes: const [],
      pickerAreaHeightPercent: pickerAreaHeightPercent,
    );
  }
}
