/// AppBottomNav — sliding pill navigation indicator.
///
/// The active item shows a teal pill background that smoothly slides
/// between tabs — more distinctive than a stock NavigationBar.
///
/// Usage:
/// ```dart
/// AppBottomNav(
///   currentIndex: _index,
///   onTap: (i) => setState(() => _index = i),
///   items: const [
///     AppNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
///     ...
///   ],
/// )
/// ```
library app_bottom_nav;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavItem> items;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: bottomPad + AppSpacing.sm,
        top: AppSpacing.sm,
        left: AppSpacing.sm,
        right: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final active = i == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                label: item.label,
                selected: active,
                button: true,
                child: AnimatedContainer(
                  duration: AppMotion.standard,
                  curve: AppMotion.easeStandard,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.micro,
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          key: ValueKey('${item.label}_$active'),
                          size: 22,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: AppMotion.micro,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? AppColors.primary : AppColors.textMuted,
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
