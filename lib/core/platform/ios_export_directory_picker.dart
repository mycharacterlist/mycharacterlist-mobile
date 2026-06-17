import 'dart:io';

import 'package:flutter/services.dart';

class IosExportDirectoryPicker {
  IosExportDirectoryPicker._();

  static const _channel = MethodChannel(
    'com.limonnyemalchiki.mycharacterlist/export_directory',
  );

  static Future<String?> pickDirectory() async {
    if (!Platform.isIOS) {
      return null;
    }

    final path = await _channel.invokeMethod<String>('pickDirectory');
    if (path == null || path.isEmpty) {
      return null;
    }

    return path;
  }

  static Future<void> stopAccessing() async {
    if (!Platform.isIOS) {
      return;
    }

    await _channel.invokeMethod<void>('stopAccessingDirectory');
  }
}
