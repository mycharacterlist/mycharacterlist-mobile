import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final exportDirectory = Directory(
        '${documentsDirectory.path}/exports',
      );
      await exportDirectory.create(recursive: true);
      return exportDirectory.path;
    }

    return FilePicker.getDirectoryPath(dialogTitle: dialogTitle);
  }
}
