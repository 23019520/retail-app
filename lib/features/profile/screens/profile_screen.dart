import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 2,
            ),
          ),
          error: (_, __) => const Center(
            child: Text('Could not load profile.',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          data: (user) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────────────
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Avatar + name ────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Menu ─────────────────────────────────────────────────
                _MenuSection(
                  title: 'Account',
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Orders',
                      onTap: () => context.go(RouteConstants.orderHistory),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Wishlist',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.base),

                // ── Admin shortcut ───────────────────────────────────────
                if (user?.isAdmin ?? false) ...[
                  _MenuSection(
                    title: 'Administration',
                    items: [
                      _MenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin Dashboard',
                        onTap: () => context.go(RouteConstants.adminDashboard),
                        iconColor: AppColors.primary,
                        labelColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],

                _MenuSection(
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.base),

                // ── Sign out ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                    title: const Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () async {
                      await ref
                          .read(authNotifierProvider.notifier)
                          .signOut();
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Menu section ──────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String         title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      color: AppColors.divider,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  }) : trailing = null;

  final IconData   icon;
  final String     label;
  final VoidCallback onTap;
  final Widget?    trailing;
  final Color?     iconColor;
  final Color?     labelColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconColor != null
              ? iconColor!.withValues(alpha: 0.12)
              : AppColors.backgroundSheet,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
    );
  }
}