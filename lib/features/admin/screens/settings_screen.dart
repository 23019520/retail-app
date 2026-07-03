import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/models/business_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _addressCtrl = TextEditingController();

  File? _newLogoFile;
  bool _initialised = false;
  bool _isSaving    = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _initFromBusiness(BusinessModel business) {
    if (_initialised) return;
    _initialised = true;
    _nameCtrl.text    = business.name;
    _phoneCtrl.text   = business.phone   ?? '';
    _emailCtrl.text   = business.email   ?? '';
    _addressCtrl.text = business.address ?? '';
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _newLogoFile = File(picked.path));
  }

  Future<void> _save(BusinessModel current) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final updated = current.copyWith(
      name:    _nameCtrl.text.trim(),
      phone:   _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      email:   _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
    );

    final success = await ref
        .read(adminSettingsProvider.notifier)
        .save(updated, newLogoFile: _newLogoFile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Settings saved' : 'Failed to save settings'),
        backgroundColor: success ? AppColors.primary : AppColors.error,
      ));
      if (success) setState(() => _newLogoFile = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminSettingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: AppLoading(),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: Center(
          child: Text(
            'Could not load settings.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      ),
      data: (business) {
        _initFromBusiness(business);

        return Scaffold(
          backgroundColor: AppColors.backgroundBase,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        _ViewStoreButton(
                          onTap: () => context.go(RouteConstants.home),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Logo ───────────────────────────────────────────
                    const _SectionTitle('Business Logo'),
                    const SizedBox(height: AppSpacing.md),
                    _LogoPicker(
                      existingUrl: business.logoUrl,
                      newFile: _newLogoFile,
                      onPick: _pickLogo,
                      onRemove: () => setState(() => _newLogoFile = null),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Business info ──────────────────────────────────
                    const _SectionTitle('Business Information'),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Business Name',
                      controller: _nameCtrl,
                      validator: (v) => Validators.required(v, fieldName: 'Name'),
                      prefixIcon: Icons.store_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        return Validators.email(v);
                      },
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Address',
                      controller: _addressCtrl,
                      maxLines: 2,
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ── Brand colour preview ────────────────────────────
                    const _SectionTitle('Brand Colours'),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _ColorSwatch(
                          label: 'Primary',
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        _ColorSwatch(
                          label: 'Secondary',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Colours are defined in your Firestore business config. Full colour picker coming soon.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    AppButton(
                      label: 'Save Settings',
                      isLoading: _isSaving,
                      onPressed: () => _save(business),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── View Store Button ─────────────────────────────────────────────────────────

class _ViewStoreButton extends StatelessWidget {
  const _ViewStoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: 'View store',
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: AppSpacing.xs),
              Text(
                'View Store',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary,
      letterSpacing: 0.3,
    ),
  );
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.existingUrl,
    required this.newFile,
    required this.onPick,
    required this.onRemove,
  });

  final String? existingUrl;
  final File?   newFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = newFile != null || existingUrl != null;

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? newFile != null
                  ? Image.file(newFile!, fit: BoxFit.cover)
                  : Image.network(existingUrl!, fit: BoxFit.cover)
              : const Icon(
                  Icons.store_outlined,
                  size: 30,
                  color: AppColors.textMuted,
                ),
        ),
        const SizedBox(width: AppSpacing.base),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_rounded, size: 16),
              label: Text(hasImage ? 'Change Logo' : 'Upload Logo'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: const Text('Remove', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}