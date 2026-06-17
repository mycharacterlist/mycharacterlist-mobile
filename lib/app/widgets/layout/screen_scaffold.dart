import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/layout/background_stack.dart';
import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';

/// Scaffold with a full-screen background asset and optional overlays.
class ScreenScaffold extends StatelessWidget {  const ScreenScaffold({
    super.key,
    this.appBar,
    required this.backgroundAssetPath,
    required this.child,
    this.overlays = const [],
    this.resizeToAvoidBottomInset = false,
    this.bodyWrapper,
  });

  final PreferredSizeWidget? appBar;
  final String backgroundAssetPath;
  final Widget child;
  final List<Widget> overlays;
  final bool resizeToAvoidBottomInset;
  final Widget Function(Widget body)? bodyWrapper;

  @override
  Widget build(BuildContext context) {
    final body = BackgroundStack(
      backgroundAssetPath: backgroundAssetPath,
      children: [
        child,
        ...overlays,
      ],
    );

    final wrappedBody = bodyWrapper != null ? bodyWrapper!(body) : body;

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: resizeToAvoidBottomInset
          ? wrappedBody
          : _KeyboardImmuneBody(child: wrappedBody),
    );
  }
}

class _KeyboardImmuneBody extends StatelessWidget {
  const _KeyboardImmuneBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemPadding = SystemViewPadding.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        viewInsets: EdgeInsets.zero,
        viewPadding: systemPadding,
        // Keep top/sides from scaffold body; only pin bottom above the nav bar.
        padding: EdgeInsets.only(
          left: mediaQuery.padding.left,
          top: mediaQuery.padding.top,
          right: mediaQuery.padding.right,
          bottom: systemPadding.bottom,
        ),
      ),
      child: child,
    );
  }
}