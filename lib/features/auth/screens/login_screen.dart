import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // Show error as snackbar whenever errorMessage changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // Header
              Text(
                'Welcome back',
                style: context.textStyles.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue shopping',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: context.colors.onSurface.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 40),

              // Form
              LoginForm(
                formKey: _formKey,
                onSubmit: (email, password) async {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .signIn(email: email, password: password);
                  // Router handles navigation on success via authStateProvider
                  // Nothing to do here if success — router redirects automatically
                },
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: const Text('Forgot password?'),
                ),
              ),

              const SizedBox(height: 24),

              // Sign in button
              AppButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Form validates itself — submit handled inside LoginForm
                    // We trigger it here so the button drives the action
                    _formKey.currentState?.validate();
                  }
                },
              ),

              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: context.colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 24),

              // Google sign in
              SocialLoginButton(
                isLoading: authState.isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signInWithGoogle();
                },
              ),

              const SizedBox(height: 40),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: context.textStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteConstants.register),
                    child: const Text('Create one'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your email and we'll send a reset link."),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordReset(emailController.text);
              if (!context.mounted) return;
              if (success) {
                context.showSnackBar('Reset link sent — check your email.');
              }
              // Errors shown via the ref.listen at screen level
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
}
