import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';

// ── Order count badge provider ────────────────────────────────────────────────

/// Order count shown as badge on the My Orders menu item.
final userOrdersCountProvider = Provider<int>((ref) {
  return ref.watch(userOrdersProvider).value?.length ?? 0;
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Could not load profile.')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('No profile found.')),
          );
        }
        return _ProfileContent(user: user);
      },
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final orderCount = ref.watch(userOrdersCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient header with avatar ────────────────────────
            ProfileHeader(user: user),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Account ──────────────────────────────────────
                  const _SectionLabel('Account'),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () => _showEditProfileSheet(context, ref, user),
                    ),
                    _MenuDivider(),
                    _MenuItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => _showChangePasswordDialog(context, ref),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Shopping ─────────────────────────────────────
                  const _SectionLabel('Shopping'),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Orders',
                      onTap: () => context.go(RouteConstants.orderHistory),
                      trailing: orderCount > 0
                          ? _CountBadge(count: orderCount, colors: colors)
                          : null,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Admin shortcut ────────────────────────────────
                  if (user.isAdmin) ...[
                    const _SectionLabel('Administration'),
                    _MenuCard(children: [
                      _MenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin Dashboard',
                        color: colors.primary,
                        onTap: () =>
                            context.go(RouteConstants.adminDashboard),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],

                  // ── Support ───────────────────────────────────────
                  const _SectionLabel('Support'),
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _MenuDivider(),
                    _MenuItem(
                      icon: Icons.policy_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Sign out ──────────────────────────────────────
                  _MenuCard(children: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      color: colors.error,
                      showArrow: false,
                      onTap: () async {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                        // Router redirect handles navigation automatically
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── Version ───────────────────────────────────────
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Edit Profile',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Full Name',
                  controller: nameCtrl,
                  validator: Validators.name,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Phone (optional)',
                  controller: phoneCtrl,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save Changes',
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      await ref
                          .read(profileProvider.notifier)
                          .updateProfile(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim().isNotEmpty
                                ? phoneCtrl.text.trim()
                                : null,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text("We'll send a password reset link to your email."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordReset(user.email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset link sent — check your email.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.color,
    this.showArrow = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? color;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final itemColor = color ?? colors.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: itemColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: itemColor,
                    ),
              ),
            ),
            // Trailing widget
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            // Arrow
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 70,
      color: Theme.of(context)
          .colorScheme
          .outline
          .withValues(alpha: 0.1),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.colors});
  final int count;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}
