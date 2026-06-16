import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/app.dart';
import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/bootstrap/image_compression_migration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppImageCache.warmUp();
  await ImageCompressionMigration.runIfNeeded();

  runApp(
    const ProviderScope(
      child: MyCharacterListApp(),
    ),
  );
}
