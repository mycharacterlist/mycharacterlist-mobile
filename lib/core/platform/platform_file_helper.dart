import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mycharacterlist/core/platform/ios_export_directory_picker.dart';
import 'package:path_provider/path_provider.dart';

class PlatformFileHelper {
  const PlatformFileHelper._();

  static Future<String?> resolvePickedFilePath(PlatformFile file) async {
    final path = file.path;

    if (path != null && path.isNotEmpty) {
      return path;
    }

    final bytes = file.bytes;
    if (bytes == null) {
      return null;
    }

    final tempDirectory = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDirectory.path}/import_${DateTime.now().microsecondsSinceEpoch}.json',
    );
    await tempFile.writeAsBytes(bytes);

    return tempFile.path;
  }

  static Future<String?> pickExportDirectory({
    required String dialogTitle,
  }) async {
    if (Platform.isIOS) {
      return IosExportDirectoryPicker.pickDirectory();
    }

    return FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
  }

  static Future<T?> withExportDirectoryAccess<T>(
    String directoryPath,
    Future<T?> Function(String directoryPath) action,
  ) async {
    try {
      return await action(directoryPath);
    } finally {
      if (Platform.isIOS) {
        await IosExportDirectoryPicker.stopAccessing();
      }
    }
  }
}
