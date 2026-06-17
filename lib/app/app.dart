import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/bootstrap/precache_app_assets.dart';
import 'package:mycharacterlist/app/router/app_router.dart';
import 'package:mycharacterlist/core/storage/app_disk_cache.dart';
import 'package:mycharacterlist/core/theme/app_theme.dart';

class MyCharacterListApp extends StatefulWidget {
  const MyCharacterListApp({super.key});

  @override
  State<MyCharacterListApp> createState() => _MyCharacterListAppState();
}

class _MyCharacterListAppState extends State<MyCharacterListApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      precacheAppBackgrounds(context);
      AppDiskCache.cleanUnused(includeDrafts: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AppImageCache.trimUnused();
      AppDiskCache.cleanUnused();
    }
  }

  @override
  void didHaveMemoryPressure() {
    AppImageCache.clearAll(
      restoreBackgrounds: () => precacheAppBackgrounds(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyCharacterList',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) {
        return ColoredBox(
          color: Colors.black,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );
  }
}
