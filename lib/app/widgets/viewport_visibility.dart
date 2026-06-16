import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

bool isWidgetVisibleInViewport(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox ||
      !renderObject.hasSize ||
      !renderObject.attached) {
    return false;
  }

  final itemRect = renderObject.localToGlobal(Offset.zero) & renderObject.size;

  final scrollable = Scrollable.maybeOf(context);
  if (scrollable != null) {
    final viewportObject = scrollable.context.findRenderObject();
    if (viewportObject is RenderBox &&
        viewportObject.hasSize &&
        viewportObject.attached) {
      final viewportRect =
          viewportObject.localToGlobal(Offset.zero) & viewportObject.size;
      return itemRect.overlaps(viewportRect);
    }
  }

  final mediaQuery = MediaQuery.of(context);
  final padding = mediaQuery.padding;
  final screenRect = Rect.fromLTWH(
    padding.left,
    padding.top,
    mediaQuery.size.width - padding.left - padding.right,
    mediaQuery.size.height - padding.top - padding.bottom,
  );

  return itemRect.overlaps(screenRect);
}

/// Re-checks marquee visibility when the parent list scrolls.
mixin ParentScrollVisibilityMixin<T extends StatefulWidget> on State<T> {
  ScrollPosition? _parentScrollPosition;

  void onParentScrollVisibilityChanged();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachParentScrollListener();
  }

  @override
  void dispose() {
    _parentScrollPosition?.removeListener(onParentScrollVisibilityChanged);
    super.dispose();
  }

  void _attachParentScrollListener() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == _parentScrollPosition) {
      return;
    }

    _parentScrollPosition?.removeListener(onParentScrollVisibilityChanged);
    _parentScrollPosition = position;
    _parentScrollPosition?.addListener(onParentScrollVisibilityChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onParentScrollVisibilityChanged();
      }
    });
  }
}
