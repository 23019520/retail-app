import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_login_button.dart';

// ══════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _passwordFocus  = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.hasError && next.errorMessage != prev?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // ── Brand mark ────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: const Icon(
                      Icons.laptop_mac_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Laptops',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotDialog(context),
                  child: const Text('Forgot password?'),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),

              const SizedBox(height: AppSpacing.lg),

              const _Divider(),

              const SizedBox(height: AppSpacing.lg),

              SocialLoginButton(
                isLoading: authState.isLoading,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteConstants.register),
                    child: const Text('Create one'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email and we'll send a reset link.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.base),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final ok = await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordReset(ctrl.text);
              if (!context.mounted) return;
              if (ok) context.showSnackBar('Reset link sent — check your email.');
            },
            child: const Text('Send link'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REGISTER SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  final _emailFocus     = FocusNode();
  final _passwordFocus  = FocusNode();
  final _confirmFocus   = FocusNode();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authNotifierProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.hasError && next.errorMessage != prev?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => context.go(RouteConstants.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Fill in your details to get started',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppSpacing.xl),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Full Name',
                      hint: 'Jane Smith',
                      controller: _nameCtrl,
                      validator: Validators.name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Email',
                      hint: 'you@example.com',
                      controller: _emailCtrl,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      focusNode: _emailFocus,
                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      validator: Validators.password,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                      focusNode: _passwordFocus,
                      onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Confirm Password',
                      hint: '••••••••',
                      controller: _confirmCtrl,
                      validator: (v) =>
                          Validators.confirmPassword(v, _passwordCtrl.text),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      focusNode: _confirmFocus,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              AppButton(
                label: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: _submit,
              ),

              const SizedBox(height: AppSpacing.lg),
              const _Divider(),
              const SizedBox(height: AppSpacing.lg),

              SocialLoginButton(
                isLoading: authState.isLoading,
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Text(
                'By creating an account you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => context.go(RouteConstants.login),
                    child: const Text('Sign in'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
