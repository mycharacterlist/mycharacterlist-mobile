import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/storage/local_file_storage.dart';

final localFileStorageProvider = Provider<LocalFileStorage>(
  (ref) => LocalFileStorage(),
);
