import 'package:flutter/material.dart';

class PatchNoteForm extends StatelessWidget {
  const PatchNoteForm({
    super.key,
    required this.versionController,
    required this.releaseDateController,
    required this.versionFocusNode,
    required this.onAdd,
    required this.isSaving,
  });

  final TextEditingController versionController;
  final TextEditingController releaseDateController;
  final FocusNode versionFocusNode;

  final Future<void> Function() onAdd;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFFECE8D8),
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        children: [
          TextField(
            controller: versionController,
            focusNode: versionFocusNode,

            decoration: const InputDecoration(
              labelText: 'Version',
              hintText: '1.0.0',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TextField(
            controller: releaseDateController,

            decoration: const InputDecoration(
              labelText: 'Release date',
              hintText: '23.06.2026',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: isSaving ? null : () => onAdd(),
              child: Text(isSaving ? 'Saving...' : 'Add patch'),
            ),
          ),
        ],
      ),
    );
  }
}
