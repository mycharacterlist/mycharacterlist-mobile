import 'dart:io';

import 'package:flutter/material.dart';

class CharacterImageViewer {
  const CharacterImageViewer._();

  static Future<void> open(BuildContext context, String imagePath) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);

        return GestureDetector(
          onTap: () => Navigator.pop(dialogContext),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: size.width * 0.95,
                  maxHeight: size.height * 0.88,
                ),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
