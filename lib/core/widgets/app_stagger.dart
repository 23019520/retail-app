/// AppStagger — fade+slide entrance animation for lists and grids.
/// Wrap each item in [AppStaggerItem] inside any list/grid builder.
library app_stagger;

import 'package:flutter/material.dart';


// ── Controller ────────────────────────────────────────────────────────────────

class AppStagger extends StatefulWidget {
  const AppStagger({
    super.key,
    required this.child,
    this.itemCount,
  });

  final Widget child;
  final int? itemCount;

  @override
  State<AppStagger> createState() => AppStaggerState();

  static AppStaggerState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppStaggerState>();
}

class AppStaggerState extends State<AppStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Item ──────────────────────────────────────────────────────────────────────

class AppStaggerItem extends StatelessWidget {
  const AppStaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.maxIndex = 8, // stagger cap — items beyond this animate together
  });

  final int index;
  final Widget child;
  final int maxIndex;

  @override
  Widget build(BuildContext context) {
    final staggerState = AppStagger.of(context);

    // No parent stagger — render immediately
    if (staggerState == null) return child;

    final cappedIndex = index.clamp(0, maxIndex);
    final start = (cappedIndex * 0.06).clamp(0.0, 0.6);
    final end   = (start + 0.4).clamp(0.0, 1.0);

    final curve = CurvedAnimation(
      parent: staggerState.controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
