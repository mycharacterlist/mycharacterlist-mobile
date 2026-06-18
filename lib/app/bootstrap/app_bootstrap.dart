import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/app.dart';
import 'package:mycharacterlist/app/bootstrap/image_compression_migration.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';

/// Runs one-time startup work after the first frame so the app does not stay
/// on a blank screen while photo migration is in progress.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _ready = false;
  ImageCompressionMigrationProgress? _progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    try {
      await ImageCompressionMigration.runIfNeeded(
        onProgress: (progress) {
          if (mounted) {
            setState(() => _progress = progress);
          }
        },
      );
    } on Object catch (error, stackTrace) {
      debugPrint(
        'Image compression migration failed: $error\n$stackTrace',
      );
    }

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return const MyCharacterListApp();
    }

    final progress = _progress;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLoadingIndicator(color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  progress?.title ?? 'Updating photos...',
                  textAlign: TextAlign.center,
                  style: AppTypography.loadingOverlayTitle,
                ),
                if (progress != null && progress.total > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${progress.completed} / ${progress.total}',
                    style: AppTypography.loadingOverlayProgress,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
