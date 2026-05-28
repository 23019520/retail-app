import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (!mounted) return;

    if (success) {
      // Check admin claim
      final isAdmin = await ref.read(isAdminProvider.future);
      if (!mounted) return;

      if (isAdmin) {
        context.go(RouteConstants.adminDashboard);
      } else {
        // Signed in but not admin — sign out and show error
        await ref.read(authNotifierProvider.notifier).signOut();
        if (mounted) {
          context.showErrorSnackBar(
              'Access denied. This account does not have admin privileges.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final colors = Theme.of(context).colorScheme;

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              // Centre the form on wide screens
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.admin_panel_settings_outlined,
                        color: colors.onPrimary, size: 28),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Admin Login',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your store',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                  ),

                  const SizedBox(height: 36),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email',
                          controller: _emailCtrl,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.email_outlined,
                          onFieldSubmitted: (_) =>
                              _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Password',
                          controller: _passwordCtrl,
                          validator: Validators.password,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline,
                          focusNode: _passwordFocus,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    label: 'Sign In',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go(RouteConstants.login),
                      child: const Text('Back to customer login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
