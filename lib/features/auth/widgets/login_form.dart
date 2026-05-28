import 'package:flutter/material.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';

/// Email + password form fields extracted into a widget.
/// Calls [onSubmit] with validated email + password.
/// The parent screen owns the FormKey so it controls when to validate.
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final void Function(String email, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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

  void _submit() {
    if (widget.formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
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
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
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
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    );
  }
}
