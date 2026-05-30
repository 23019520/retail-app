import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // Single submit method — called by button AND keyboard done action
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    // Router handles navigation automatically on success
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

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

              // Form — controllers live here now, not in a sub-widget
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailController,
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
                      hint: '••••••••',
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      focusNode: _passwordFocus,
                      // Keyboard done button also submits
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
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

              // Sign in button — directly calls _submit()
              AppButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _submit,
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
                  ref
                      .read(authNotifierProvider.notifier)
                      .signInWithGoogle();
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
    final emailController =
        TextEditingController(text: _emailController.text);

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
                context.showSnackBar(
                    'Reset link sent — check your email.');
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }
}
